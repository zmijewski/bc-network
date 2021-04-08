# frozen_string_literal: true

module Services
  class Transactions

    def create(from:, to:, blockchain:)
      amount = [rand(1..blockchain.compute_balances[from.public_key]), 500].min
      ::Transaction.new(
        from: from.public_key,
        to: to.public_key,
        amount: amount,
        private_key: from.private_key
      )
    end
  end
end
