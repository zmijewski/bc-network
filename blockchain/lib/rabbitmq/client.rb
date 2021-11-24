# frozen_string_literal: true

require 'bunny'

module RabbitMQ
  class Client
    extend Dry::Initializer

    option :max_tries, default: proc { 5 }
    option :hostname, default: proc { 'queue' }
    option :channel, default: proc {
      connection = Bunny.new(hostname: hostname, automatically_recover: false)
      tries = 0
      while tries <= max_tries
        begin
          connection.start
          break
        rescue Bunny::TCPConnectionFailedForAllHosts => _e
          tries += 1
          sleep(tries)
        end
      end

      connection.create_channel
    }

    def subscribe(queue_name:, &handler)
      queue = channel.queue(queue_name)

      begin
        queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
          handler.call(body, delivery_info)
        end
      rescue Interrupt => _e
        connection.close

        exit(0)
      end
    end

    def acknowledge(delivery_tag)
      channel.ack(delivery_tag)
    end
  end
end
