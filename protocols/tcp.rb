# frozen_string_literal: true

module Protocols
  module Exceptions
    ConnectionError = Class.new(StandardError)
    ServerShutdown  = Class.new(StandardError)
  end

  class TCPServer
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

  class TCPClient
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
