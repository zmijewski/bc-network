require "socket"
require "pry"
require "json"
require "set"

host = "127.0.0.1"
port = 80

peers = Set.new([])

Socket.tcp_server_loop(port) do |socket|
   result = JSON.parse(socket.read)
   if result["event"] == "add"
      puts "Add address #{result['address']}"
      peers.add(result["address"])
   elsif result["event"] == "remove"
      puts "Remove address #{result['address']}"
      peers.delete(result["address"])
   end
   socket.write(peers.to_a)
   puts "Current peer list #{peers}"
ensure
   socket.close
end
