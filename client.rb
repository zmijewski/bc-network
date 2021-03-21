require "socket"
require "pry"
require "json"
require "set"
require "securerandom"
require "concurrent-ruby"

PORT, NAME = ARGV.first(2)

client_id   = NAME
client_port = PORT.to_i

puts "Hello my name is #{client_id}"

server_host = "127.0.0.1"
server_port = 2000

peers_ports = Concurrent::Set.new([])

TCPSocket.open(server_host, server_port) do |socket|
  socket.write({event: "add", port: client_port, id: client_id}.to_json)
  socket.close_write

  peers = Set.new(JSON.parse(socket.read))
  peers_ports.merge(peers)

  socket.close
end

Thread.new do
  loop do
    # puts "My peers: #{peers_ports}"
    peers_ports.each do |peer_port|
      begin
        TCPSocket.open("127.0.0.1", peer_port) do |socket|
          socket.write({ message: "#{client_id} says hello!", port: client_port }.to_json)
          socket.close_write
          socket.close
        end
      rescue Errno::ECONNREFUSED => e
        peers_ports.delete(peer_port)
      end
    end

    sleep rand(5..10)
  end
end

puts "I am ready to chit-chat..."

begin
  Socket.tcp_server_loop(client_port) do |socket|
    result = JSON.parse(socket.read)
    puts("#{client_id} received: #{result['message']}")
    peers_ports.add(result['port'])
  ensure
    socket.close
  end
rescue Interrupt => e
  peers_ports.each do |peer_port|
    begin
      TCPSocket.open("127.0.0.1", peer_port) do |socket|
        socket.write({ message: "#{client_id} says bye!", port: client_port }.to_json)
        socket.close_write
        socket.close
      end
    rescue Errno::ECONNREFUSED => e
      peers_ports.delete(peer_port)
    end
  end

  TCPSocket.open(server_host, server_port) do |socket|
    socket.write({event: "remove", port: client_port, id: client_id}.to_json)
    socket.close_write
    socket.close
  end
  puts "Exiting gracely ..."
  exit 0
end
