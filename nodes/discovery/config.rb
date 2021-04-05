module Nodes
  module Discovery
    class Config
      attr_reader :peer, :peers

      def initialize(
        peer: Peer.new(host: "discovery_node", port: 80),
        peers: Set.new
      )
        @peer  = peer
        @peers = peers
      end
    end
  end
end
