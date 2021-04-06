# frozen_string_literal: true

module Nodes
  module Full
    class Client
      extend Dry::Initializer

      attr_reader :peer, :peers, :discovery

      option :peer,      default: proc { Peer.new(host: IPSocket.getaddress(Socket.gethostname), port: 80) }
      option :peers,     default: proc { Concurrent::Set.new }
      option :protocol,  default: proc { Protocols::TCPClient.new }
      option :discovery

      def gossip_with(other_peer:)
        send(message: gossip_message, other_peer: other_peer)
      rescue Protocols::Exceptions::ConnectionError
        peers.delete(other_peer)
      end

      def sync_discovery
        result = send(message: sync_discovery_message, other_peer: discovery.peer)
        discovery_peers = result.map { |other_peer| Peer.new(other_peer) }

        peers.merge(discovery_peers)
        peers.delete(peer)
      end

      def notify_discovery_server_down
        send(message: shutdown_message, other_peer: discovery.peer)
      end

      def notify_peers_server_down
        peers.each do |other_peer|
          begin
            send(message: shutdown_message, other_peer: other_peer)
          rescue Protocols::Exceptions::ConnectionError
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

      def send(message:, other_peer:)
        LOGGER.info("[#{peer}] I gossip with #{other_peer}")
        protocol.send(message: message, peer: other_peer)
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
