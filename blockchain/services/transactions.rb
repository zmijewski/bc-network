# frozen_string_literal: true

module Services
  class Transactions
<<<<<<< HEAD
=======
    extend Dry::Initializer

    option :owner
>>>>>>> a09dfba... Reduced dependency on transactions service

    def create(from:, to:, blockchain:)
      amount = [rand(1..blockchain.compute_balances[from.public_key]), 500].min
      ::Transaction.new(
        from: from.public_key,
        to: to.public_key,
        amount: amount,
        private_key: from.private_key
      )
    end
<<<<<<< HEAD
=======

    def create_public_transaction(request)
      ::Transaction.new(
        from: request.params[:from],
        to: request.params[:to],
        amount: request.params[:amount],
        private_key: owner.private_key
      )
    end
>>>>>>> a09dfba... Reduced dependency on transactions service
  end
end
