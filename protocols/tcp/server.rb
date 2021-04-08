# frozen_string_literal: true

module Protocols
  module TCP
    class Server
      def listen(peer:, &request_handler)
        Socket.tcp_server_loop(peer.port) do |socket|
          Thread.new do
            request  = JSON.parse(socket.read)
            response = request_handler.call(request)
            socket.write(response)
            socket.close
          end
        end
      rescue Interrupt, SignalException => e
        raise Protocols::Exceptions::ServerShutdown, e
      end
    end
  end
end
