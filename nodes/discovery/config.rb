module Nodes
  module Discovery
    class DiscoveryConfig
      attr_reader :host, :port, :peers

      def initialize(host: "discovery", port: 80, peers: Set.new)
        @host  = host
        @port  = port
        @peers = peers
      end
    end
  end
end
