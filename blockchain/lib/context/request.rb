# frozen_string_literal: true

require 'securerandom'

module Context
  class Request
    def initialize(request)
      @request = request.transform_keys!(&:to_sym)
      @request.merge!(request_id: SecureRandom.uuid) unless decorated?
    end

    def request_id
      @request[:request_id]
    end

    def params
      @request
    end

    private

    def decorated?
      @request.key?(:request_id)
    end
  end
end
