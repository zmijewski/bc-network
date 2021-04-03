module Nodes
  module Discovery
    class Server
      def initialize(config: nil)
        @config = config
      end

      def run
        Socket.tcp_server_loop(config.port) do |socket|
          Thread.new do
            handle_request(socket)
          end
        ensure
          socket.close
        end
      end

      private

      attr_reader :config

      def handle_request(socket)
        request = JSON.parse(socket.read)

        case request["event"]
        when "update"
          config.peers.add({ host: request["host"], port: request["port"] })
        when "remove"
          config.peers.delete({ host: request["host"], port: request["port"] })
        end

        socket.write(config.peers.to_a)
      end
    end
  end
end
