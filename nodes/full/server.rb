module Nodes
  module Node
    class Server
      def initialize(client)
        @client = client
      end

      def run
        begin
          Socket.tcp_server_loop(client.port) do |socket|
            Thread.new do
              handle_request(socket)
            end
          ensure
            socket.close
          end
        rescue Interrupt, SignalException => e
          client.notify_peers_server_down
          client.notify_master_server_down
          exit 0
        end
      end

      private

      attr_reader :client

      def handle_request(socket)
        request = JSON.parse(socket.read)

        case request["event"]
        when "update"
          client.update_peers(other_peers: Concurrent::Set.new(request["peers"]))
        when "remove"
          client.delete_peer(other_peer: request["host"])
        end
      end
    end
  end
end
