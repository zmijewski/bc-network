# frozen_string_literal: true

module Nodes
  module Full
    class Server
      extend Dry::Initializer

      option :client
      option :protocol, default: proc { ::Protocols::TCP::Server.new }

      def run
        protocol.listen(peer: client.peer) do |request|
          handle_request(request)
        end
      rescue ::Protocols::Exceptions::ServerShutdown
        shutdown_gracefully
      end

      private

      attr_reader :client

      def handle_request(request)
        response = {}

        case request['event']
        when 'update'
          client.update_peers(request)
          client.update_blockchain(request)
        when 'remove'
          client.delete_peer(request)
        when 'public_key'
          response = client.public_key_response
        end

        response.to_json
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
