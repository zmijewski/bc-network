# frozen_string_literal: true

module Metrics
  module Instruments
    def self.time_around
      start_time = Time.now.utc

      yield

      Time.now.utc - start_time
    end
  end
end
