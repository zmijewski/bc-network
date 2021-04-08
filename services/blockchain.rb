# frozen_string_literal: true

module Services
  class Blockchain
    extend Dry::Initializer

    attr_reader :blockchain

    option :blockchain, default: proc { nil }

    def create(peer:)
      @blockchain = ::Blockchain.new(public_key: peer.public_key, private_key: peer.private_key)
    end

    def add_to_chain(transaction:)
      @blockchain.add_to_chain(transaction: transaction)
    end

    def ready?(peer:)
      !blockchain.nil? && blockchain.compute_balances[peer.public_key].positive?
    end

    def handle_blockchain_update(request)
      other_blockchain = YAML.safe_load(request['blockchain'], [::Blockchain, ::Block, ::Transaction], aliases: true)

      return if other_blockchain.nil?
      return if blockchain && other_blockchain.length <= blockchain.length
      return unless other_blockchain.valid?

      @blockchain = other_blockchain

      LOGGER.info("Blockchain has #{blockchain.length} transactions")
    end
  end
end
