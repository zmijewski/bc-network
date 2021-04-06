# frozen_string_literal: true

module Nodes
  module Discovery
    class Config
      extend Dry::Initializer

      attr_reader :peer, :peers

      option :peer,  default: proc { Peer.new(host: 'discovery_node', port: 80) }
      option :peers, default: proc { Set.new }
    end
  end
end
