# frozen_string_literal: true

module Protocols
  module Exceptions
    ConnectionError = Class.new(StandardError)
    ServerShutdown  = Class.new(StandardError)
  end
end
