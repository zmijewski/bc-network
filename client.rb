require "socket"
require "pry"
require "json"
require "set"
require "concurrent-ruby"

client_address = IPSocket.getaddress(Socket.gethostname)
client_port    = 80

server_host = "master_node"
server_port = 80
peer_port   = 80

peers = Concurrent::Set.new([])

TCPSocket.open(server_host, server_port) do |socket|
  socket.write({ event: "add", address: client_address }.to_json)
  socket.close_write

  peers.merge(Set.new(JSON.parse(socket.read)))
ensure
  socket.close
end

Thread.new do
  loop do
    sleep rand(5..10)
    puts "I have #{peers.size - 1} peers!"

    peer_address = peers.to_a.sample

    next if peer_address == client_address
    puts "Current peer #{peer_address}"

    begin
      TCPSocket.open(peer_address, peer_port) do |socket|
        socket.write({ message: "#{client_address} says hello!", event: "add", address: client_address, peers: peers.to_a }.to_json)
        socket.close_write
        socket.close
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      peers.delete(peer_address)
    end
  end
end

puts "I am ready to chit-chat..."

begin
  Socket.tcp_server_loop(client_port) do |socket|
    result = JSON.parse(socket.read)
    puts("Client #{IPSocket.getaddress(Socket.gethostname)} received: #{result['message']}")
    if result["event"] == "add"
      peers.add(result["address"])
      peers.merge(Set.new(result["peers"]))
    elsif result["event"] == "remove"
      puts "Bye friend #{result['address']}!"
      peers.delete(result["address"])
    end
  ensure
    socket.close
  end
rescue Interrupt, SignalException => e
  peers.each do |peer_address|
    begin
      TCPSocket.open(peer_address, peer_port) do |socket|
        socket.write({ message: "#{client_address} says bye!", event: "remove", address: client_address }.to_json)
        socket.close_write
        socket.close
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      puts "I am sad, #{peer_address} had to disappear"
    end
  end

  TCPSocket.open(server_host, server_port) do |socket|
    socket.write({event: "remove", address: client_address}.to_json)
    socket.close_write
    socket.close
  end
  puts "Exiting gracely ..."
  exit 0
end
