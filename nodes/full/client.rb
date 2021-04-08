# frozen_string_literal: true

module Nodes
  module Full
    class Client
      extend Dry::Initializer

      option :discovery
      option :peers_service
      option :blockchain_service
      option :transactions_service, default: proc { ::Services::Transactions.new }

      def send_money(peer:)
        peer_public_key = peers_service.public_key(peer: peer)

        transaction = transactions_service.create(
          from: peers_service.owner,
          to: ::PublicPeer.new(peer.to_hash.merge(public_key: peer_public_key)),
          blockchain: blockchain_service.blockchain
        )

        blockchain_service.add_to_chain(transaction: transaction)
      end

      def gossip(peer:)
        peers_service.gossip(peer: peer, blockchain: blockchain_service.blockchain)
      end

      def discover
        peers_service.discover(peer: discovery)

        return unless peers_service.peers.empty?

        blockchain_service.create(peer: peers_service.owner)
      end

      def peers
        peers_service.peers
      end

      def ready?
        blockchain_service.ready?(peer: peers_service.owner)
      end
    end
  end
end
