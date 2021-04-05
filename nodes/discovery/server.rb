module Nodes
  module Discovery
    class Server
      def initialize(config: nil)
        @config = config
      end

      def run
        Socket.tcp_server_loop(config.peer.port) do |socket|
          Thread.new do
            handle_request(socket)
          end
        end
      rescue Interrupt, SignalException => e
        LOGGER.info("Discovery serves goes down!")
      end

      private

      attr_reader :config

      def handle_request(socket)
        request = JSON.parse(socket.read)
        peer = Peer.new(request["peer"])

        case request["event"]
        when "update"
          LOGGER.info("New peer is joining our network: #{peer}")
          config.peers.add(peer)
        when "remove"
          config.peers.delete(peer)
          LOGGER.info("#{peer} peer has left our network: #{peer}")
        end

        socket.write(config.peers.map(&:to_hash).to_json)
        socket.close
      end
    end
  end
end
