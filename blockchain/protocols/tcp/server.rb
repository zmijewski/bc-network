# frozen_string_literal: true

module Protocols
  module TCP
    class Server
      def listen(peer:, &request_handler)
        Socket.tcp_server_loop(peer.port) do |socket|
          Thread.new do
            request         = JSON.parse(socket.read)
            context_request = Context::Request.new(request)

            time = Metrics::Instruments.time_around do
              response = request_handler.call(context_request)
              socket.write(response)
              socket.close
            end

            Metric.new(
              name: 'request_time',
              properties: {
                time: time,
                request_id: context_request.request_id
              }
            ).send
          end
        end
      rescue Interrupt, SignalException => e
        raise Protocols::Exceptions::ServerShutdown, e
      end
    end
  end
end
