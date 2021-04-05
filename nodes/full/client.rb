module Nodes
  module Full
    class Client
      attr_reader :peer, :peers, :discovery

      def initialize(
        peer: Peer.new(host: IPSocket.getaddress(Socket.gethostname), port: 80),
        peers: Concurrent::Set.new,
        discovery: nil
      )
        @peer      = peer
        @peers     = peers
        @discovery = discovery

        sync_discovery

        Thread.new do
          loop do
            other_peer = peers.to_a.sample
            next unless other_peer

            LOGGER.info("[#{peer}] I gossip with #{other_peer}")
            gossip_with(other_peer: other_peer)
            sleep(rand(3..5))
          end
        end
      end

      def gossip_with(other_peer:)
        TCPSocket.open(other_peer.host, other_peer.port) do |socket|
          socket.write(gossip_message)
          socket.close_write
          socket.close
        end
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
        peers.delete(other_peer)
      end

      def sync_discovery
        TCPSocket.open(discovery.peer.host, discovery.peer.port) do |socket|
          socket.write(sync_discovery_message)
          socket.close_write
          discovery_peers = JSON.parse(socket.read).map { |other_peer| Peer.new(other_peer) }
          socket.close

          peers.merge(discovery_peers)
          # make sure client host is not in the peers
          peers.delete(peer)
          LOGGER.info("My peers #{peers.map(&:to_s).join(", ")}")
        end
      end

      def notify_discovery_server_down
        TCPSocket.open(discovery.peer.host, discovery.peer.port) do |socket|
          socket.write(shutdown_message)
          socket.close_write
          socket.close
        end
      end

      def notify_peers_server_down
        peers.each do |other_peer|
          begin
            TCPSocket.open(other_peer.host, other_peer.port) do |socket|
              socket.write(shutdown_message)
              socket.close_write
              socket.close
            end
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            # cannot reach the other_peer
          end
        end
      end

      def update_peers(request)
        other_peers = request["peers"] + [(request["peer"])]
        peers.merge(other_peers.map { |other_peer| Peer.new(other_peer) })
        # make sure client host is not in the peers
        peers.delete(peer)
        LOGGER.info("Peers after update: #{peers.map(&:to_s).join(", ")}")
      end

      def delete_peer(request)
        peers.delete(Peer.new(request["peer"]))
        LOGGER.info("Peers after delete: #{peers.map(&:to_s).join(", ")}")
      end

      def update_blockchain
      end

      private

      def gossip_message
        {
          peer: peer.to_hash,
          event: "update",
          blockchain: "blockchain",
          peers: peers.map(&:to_hash),
        }.to_json
      end

      def sync_discovery_message
        {
          peer: peer.to_hash,
          event: "update",
        }.to_json
      end

      def shutdown_message
        {
          peer: peer.to_hash,
          event: "remove",
        }.to_json
      end
    end
  end
end
