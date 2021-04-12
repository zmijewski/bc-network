# frozen_string_literal: true

module Nodes
  module Full
    class Server
      extend Dry::Initializer

      option :peers_service
      option :blockchain_service
      option :protocol, default: proc { ::Protocols::TCP::Server.new }
      option :discovery

      def run
        protocol.listen(peer: peers_service.owner) do |request|
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
          peers_service.handle_peers_update(request)
          blockchain_service.handle_blockchain_update(request)
        when 'remove'
          peers_service.handle_peer_delete(request)
        when 'public_key'
          response = peers_service.handle_public_key
        end

        response.to_json
      end

      def shutdown_gracefully
        LOGGER.info("Node #{peers_service.owner.host}:#{peers_service.owner.port} is leaving!")
        peers_service.notify_peer_server_down(peer: discovery)
        peers_service.peers.each do |peer|
          peers_service.notify_peer_server_down(peer: peer)
        end
        exit 0
      end
    end
  end
end
