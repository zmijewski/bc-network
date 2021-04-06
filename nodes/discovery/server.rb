# frozen_string_literal: true

module Nodes
  module Discovery
    class Server
      extend Dry::Initializer

      option :config
      option :protocol, default: proc { Protocols::TCPServer.new }

      def run
        protocol.listen(peer: config.peer) do |request|
          handle_request(request)
        end
      rescue ::Protocols::Exceptions::ServerShutdown
        LOGGER.info('Discovery serves goes down!')
      end

      private

      attr_reader :config

      def handle_request(request)
        peer = request['peer']

        case request['event']
        when 'update'
          config.peers.add(peer)
        when 'remove'
          config.peers.delete(peer)
        end

        config.peers.map(&:to_hash).to_json
      end
    end
  end
end
