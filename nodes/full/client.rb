# frozen_string_literal: true

module Nodes
  module Full
    class Client
      extend Dry::Initializer

      attr_reader :peer, :peers, :discovery

      option :peer,      default: proc { Peer.new(host: IPSocket.getaddress(Socket.gethostname), port: 80) }
      option :peers,     default: proc { Concurrent::Set.new }
      option :discovery

      def gossip_with(other_peer:)
        send(other_peer: other_peer, message: gossip_message)
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
        peers.delete(other_peer)
      end

      def sync_discovery
        result = send(other_peer: discovery.peer, message: sync_discovery_message)
        discovery_peers = JSON.parse(result).map { |other_peer| Peer.new(other_peer) }
        peers.merge(discovery_peers)
        # make sure client host is not in the peers
        peers.delete(peer)
        LOGGER.info("My peers #{peers.map(&:to_s).join(', ')}")
      end

      def notify_discovery_server_down
        send(other_peer: discovery.peer, message: shutdown_message)
      end

      def notify_peers_server_down
        peers.each do |other_peer|
          begin
            send(other_peer: other_peer, message: shutdown_message)
          rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
            # cannot reach the other_peer
          end
        end
      end

      def update_peers(request)
        other_peers = request['peers'] + [(request['peer'])]
        peers.merge(other_peers.map { |other_peer| Peer.new(other_peer) })
        # make sure client host is not in the peers
        peers.delete(peer)
      end

      def delete_peer(request)
        peers.delete(Peer.new(request['peer']))
      end

      def update_blockchain; end

      private

      def send(other_peer:, message:)
        LOGGER.info("[#{peer}] I gossip with #{other_peer}")
        result = nil
        TCPSocket.open(other_peer.host, other_peer.port) do |socket|
          socket.write(message)
          socket.close_write
          result = socket.read
          socket.close
        end
        result
      end

      def gossip_message
        {
          peer: peer.to_hash,
          event: 'update',
          blockchain: 'blockchain',
          peers: peers.map(&:to_hash)
        }.to_json
      end

      def sync_discovery_message
        {
          peer: peer.to_hash,
          event: 'update'
        }.to_json
      end

      def shutdown_message
        {
          peer: peer.to_hash,
          event: 'remove'
        }.to_json
      end
    end
  end
end
