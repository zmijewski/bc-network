require "socket"
require "pry"
require "json"
require "set"

host = "127.0.0.1"
port = 2000

peers_ports = Set.new([])

Socket.tcp_server_loop(port) do |socket|
   result = JSON.parse(socket.read)
   socket.write(peers_ports.to_a)
   if result["event"] == "add"
      puts "Add id #{result['id']}"
      peers_ports.add(result["port"])
   elsif result["event"] == "remove"
      puts "Remove id #{result['id']}"
      peers_ports.delete(result["port"])
   end
ensure
   socket.close
end
