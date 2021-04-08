# frozen_string_literal: true

module Protocols
  module TCP
    class Client
      def send(message: nil, peer: nil)
        result = process(message, peer)
        JSON.parse(result)
      rescue JSON::ParserError
        {}
      end

      private

      def process(message, peer)
        result = nil

        TCPSocket.open(peer.host, peer.port) do |socket|
          socket.write(message)
          socket.close_write
          result = socket.read
          socket.close
        end

        result
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
        raise ::Protocols::Exceptions::ConnectionError, e
      end
    end
  end
end
