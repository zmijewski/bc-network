# frozen_string_literal: true

module Services
  class Peers
    extend Dry::Initializer

    option :peers_aggregate
    option :protocol, default: proc { ::Protocols::TCP::Client.new }

    # Client handlers

    def gossip(peer:, blockchain:)
      protocol.send(
        peer: peer,
        message: gossip_request(blockchain)
      )
    rescue ::Protocols::Exceptions::ConnectionError
      peers_aggregate.delete(other_peer)
    end

    def discover(peer:)
      result = protocol.send(
        peer: peer,
        message: sync_discovery_request
      )
      discovery_peers = result.map { |other_peer| ::Peer.new(other_peer) }
      peers_aggregate.create(discovery_peers)
    end

    def notify_peer_server_down(peer:)
      protocol.send(
        peer: peer,
        message: shutdown_request
      )
    rescue ::Protocols::Exceptions::ConnectionError
      # cannot reach the peer
    end

    def public_key(peer:)
      result = protocol.send(
        peer: peer,
        message: public_key_request
      )
      result['public_key']
    rescue ::Protocols::Exceptions::ConnectionError
      peers_aggregate.delete(other_peer)
    end

    # Server handlers

    def handle_peers_update(request)
      requested_peers_data = request.params[:peers] + [request.params[:peer]]
      other_peers = requested_peers_data.map { |other_peer| ::Peer.new(other_peer) }

      peers_aggregate.create(other_peers)
    end

    def handle_peer_delete(request)
      peers_aggregate.delete(::Peer.new(request.params[:peer]))
    end

    def handle_public_key
      {
        peer: owner.to_hash,
        public_key: owner.public_key
      }
    end

    # Helpers

    def owner
      peers_aggregate.owner
    end

    def peers
      peers_aggregate.peers
    end

    private

    def gossip_request(blockchain)
      {
        peer: owner.to_hash,
        event: 'update',
        blockchain: YAML.dump(blockchain),
        peers: peers.map(&:to_hash)
      }
    end

    def public_key_request
      {
        peer: owner.to_hash,
        event: 'public_key'
      }
    end

    def sync_discovery_request
      {
        peer: owner.to_hash,
        event: 'update'
      }
    end

    def shutdown_request
      {
        peer: owner.to_hash,
        event: 'remove'
      }
    end
  end
end
