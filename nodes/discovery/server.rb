# frozen_string_literal: true

module Nodes
  module Discovery
    class Server
      extend Dry::Initializer

      option :peer
      option :protocol,        default: proc { Protocols::TCPServer.new }
      option :peers_aggregate, default: proc { Aggregates::Peers.new(owner: peer) }

      def run
        protocol.listen(peer: peer) do |request|
          handle_request(request)
        end
      rescue ::Protocols::Exceptions::ServerShutdown
        LOGGER.info('Discovery serves goes down!')
      end

      private

      attr_reader :peer, :peers_aggregate

      def handle_request(request)
        peer = Peer.new(request['peer'])

        case request['event']
        when 'update'
          peers_aggregate.create(peer)
        when 'remove'
          peers_aggregate.delete(peer)
        end

        peers_aggregate.peers.map(&:to_hash).to_json
      end
    end
  end
end
