# frozen_string_literal: true

module Nodes
  module Discovery
    class Server
      extend Dry::Initializer

      option :config

      def run
        Socket.tcp_server_loop(config.peer.port) do |socket|
          Thread.new do
            request = JSON.parse(socket.read)
            handle_request(request)
            socket.write(config.peers.map(&:to_hash).to_json)
            socket.close
          end
        end
      rescue Interrupt, SignalException
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
      end
    end
  end
end
