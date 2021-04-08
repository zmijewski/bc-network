# frozen_string_literal: true

module Aggregates
  class Peers
    extend Dry::Initializer

    attr_reader :owner

    option :owner
    option :source, default: proc { ::Concurrent::Set.new }

    def create(peers)
      if peers.is_a? Enumerable
        source.merge(peers)
        source.delete(owner)
      else
        source.add(peers)
      end
    end

    def delete(peers)
      if peers.is_a? Enumerable
        source.subtract(peers)
      else
        source.delete(peers)
      end
    end

    def peers
      source.dup
    end
  end
end
