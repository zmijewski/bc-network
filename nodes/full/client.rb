# frozen_string_literal: true

module Nodes
  module Full
    class Client
      extend Dry::Initializer

      attr_reader :peer, :discovery

      option :peer,            default: proc { Peer.new(host: IPSocket.getaddress(Socket.gethostname), port: 80) }
      option :peers_aggregate, default: proc { Aggregates::Peers.new(owner: peer) }
      option :protocol,        default: proc { Protocols::TCPClient.new }
      option :discovery

      def gossip_with(other_peer:)
        send(message: gossip_message, other_peer: other_peer)
      rescue Protocols::Exceptions::ConnectionError
        peers_aggregate.delete(other_peer)
      end

      def sync_discovery
        result = send(message: sync_discovery_message, other_peer: discovery)
        discovery_peers = result.map { |other_peer| Peer.new(other_peer) }

        peers_aggregate.create(discovery_peers)
      end

      def notify_discovery_server_down
        send(message: shutdown_message, other_peer: discovery)
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
        requested_peers_data = request['peers'] + [(request['peer'])]
        other_peers = requested_peers_data.map { |other_peer| Peer.new(other_peer) }

        peers_aggregate.create(other_peers)
      end

      def delete_peer(request)
        peers_aggregate.delete(Peer.new(request['peer']))
      end

      def update_blockchain; end

      def peers
        peers_aggregate.peers
      end

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
