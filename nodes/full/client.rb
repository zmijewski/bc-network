# frozen_string_literal: true

module Nodes
  module Full
    class Client
      extend Dry::Initializer

      attr_reader :peer, :discovery, :public_key

      option :peer,            default: proc { Peer.new(host: IPSocket.getaddress(Socket.gethostname), port: 80) }
      option :peers_aggregate, default: proc { Aggregates::Peers.new(owner: peer) }
      option :protocol,        default: proc { Protocols::TCPClient.new }
      option :public_key
      option :private_key
      option :blockchain,      default: proc { nil }
      option :discovery

      def send_money(other_peer:)
        other_peer_public_key = get_public_key(other_peer: other_peer)['public_key']

        amount      = [rand(1..@blockchain.compute_balances[public_key]), 500].min
        transaction = Transaction.new(public_key, other_peer_public_key, amount, private_key)

        @blockchain.add_to_chain(transaction)
      end

      def gossip_with(other_peer:)
        send(message: gossip_message, other_peer: other_peer)
      rescue Protocols::Exceptions::ConnectionError
        peers_aggregate.delete(other_peer)
      end

      def sync_discovery
        result = send(message: sync_discovery_message, other_peer: discovery)
        discovery_peers = result.map { |other_peer| Peer.new(other_peer) }

        peers_aggregate.create(discovery_peers)

        return unless peers.empty?

        LOGGER.info("I am progenitor!")
        @blockchain = BlockChain.new(public_key, private_key)
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

      def update_blockchain(request)
        other_blockchain = YAML.load(request['blockchain'])

        return if other_blockchain.nil?
        return if blockchain && other_blockchain.length <= blockchain.length
        return unless other_blockchain.valid?

        @blockchain = other_blockchain
        LOGGER.info("My balance: #{@blockchain.compute_balances[public_key]}")
      end

      def public_key_response
        {
          peer: peer,
          public_key: public_key
        }
      end

      def peers
        peers_aggregate.peers
      end

      def ready?
        !blockchain.nil? && blockchain.compute_balances[public_key].positive?
      end

      private

      attr_reader :private_key

      def get_public_key(other_peer:)
        send(message: public_key_message, other_peer: other_peer)
      rescue Protocols::Exceptions::ConnectionError
        peers_aggregate.delete(other_peer)
      end

      def send(message:, other_peer:)
        # LOGGER.info("[#{peer}] I gossip with #{other_peer}")
        protocol.send(message: message, peer: other_peer)
      end

      def gossip_message
        {
          peer: peer.to_hash,
          event: 'update',
          blockchain: YAML.dump(blockchain),
          peers: peers.map(&:to_hash)
        }.to_json
      end

      def public_key_message
        {
          peer: peer.to_hash,
          event: 'public_key'
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
