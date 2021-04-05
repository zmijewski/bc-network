module Nodes
  module Full
    class Server
      def initialize(client:)
        @client = client
      end

      def run
        Socket.tcp_server_loop(client.peer.port) do |socket|
          request = JSON.parse(socket.read)
          Thread.new do
            handle_request(request)
          end
          socket.close
        end
      rescue Interrupt, SignalException => e
        LOGGER.info("I am leaving! :bye:")
        client.notify_peers_server_down
        client.notify_discovery_server_down
        exit 0
      end

      private

      attr_reader :client

      def handle_request(request)
        case request["event"]
        when "update"
          client.update_peers(request)
        when "remove"
          client.delete_peer(request)
        end
      end
    end
  end
end
