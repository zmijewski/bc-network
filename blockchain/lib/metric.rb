# frozen_string_literal: true

class Metric
  attr_reader :name, :count, :properties

  def initialize(name:, count: 1, properties: {})
    @name       = name
    @count      = count
    @properties = properties
  end

  def send
    LOGGER.info({ name: @name, count: @count, properties: @properties })
  end
end
