# frozen_string_literal: true

module Nodes
  module Full
    class Server
      extend Dry::Initializer

      option :client

      def run
        Socket.tcp_server_loop(client.peer.port) do |socket|
          request = JSON.parse(socket.read)
          Thread.new { handle_request(request) }
          socket.close
        end
      rescue Interrupt, SignalException
        shutdown_gracefully
      end

      private

      attr_reader :client

      def handle_request(request)
        case request['event']
        when 'update'
          client.update_peers(request)
        when 'remove'
          client.delete_peer(request)
        end
      end

      def shutdown_gracefully
        LOGGER.info("Node #{client.peer} is leaving!")
        client.notify_peers_server_down
        client.notify_discovery_server_down
        exit 0
      end
    end
  end
end
