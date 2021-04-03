module Nodes
  module Node
    class Client
      attr_reader :host, :port, :peers, :discovery

      def initialize(
        host: IPSocket.getaddress(Socket.gethostname),
        port: 80,
        peers: Concurrent::Set.new,
        discovery: nil
      )
        @host      = host
        @port      = 80
        @peers     = Concurrent::Set.new([])
        @discovery = discovery

        sync_discovery
      end

      def gossip_with(peer:)
        begin
          TCPSocket.open(peer.host, peer.port) do |socket|
            socket.write(gossip_message)
            socket.close_write
          end
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
          peers.delete(peer_address)
        ensure
          socket.close
        end
      end

      def sync_discovery
        TCPSocket.open(discovery.host, discovery.port) do |socket|
          socket.write(sync_discovery_message)
          socket.close_write

          discovery_peers = JSON.parse(socket.read)

          peers.merge(discovery_peers)
          # make sure client host is not in the peers
          peers.delete(host)
        ensure
          socket.close
        end
      end

      def notify_discovery_server_down
        TCPSocket.open(discovery.host, discovery.port) do |socket|
          socket.write(shutdown_message)
          socket.close_write
        ensure
          socket.close
        end
      end

      def notify_peers_server_down
        peers.each do |peer|
          begin
            TCPSocket.open(peer.host, peer.port) do |socket|
              socket.write(shutdown_message)
              socket.close_write
            end
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            # cannot reach the peer
          ensure
            socket.close
          end
        end
      end

      def update_peers(other_peers:)
        peers.merge(other_peers)
        # make sure client host is not in the peers
        peers.delete(host)
      end

      def delete_peer(other_peer:)
        peers.delete(other_peer)
      end

      def update_blockchain
      end

      private

      def gossip_message
        {
          host: host,
          port: port,
          event: "update",
          blockchain: "blockchain",
          peers: peers.to_a,
        }.to_json
      end

      def sync_discovery_message
        {
          host: host,
          port: port,
          event: "update",
        }.to_json
      end

      def shutdown_message
        {
          host: host,
          port: port,
          event: "remove",
        }.to_json
      end
    end
  end
end
