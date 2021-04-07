# frozen_string_literal: true

class Block
  extend Dry::Initializer

  attr_reader :own_hash, :previous_block_hash, :transaction

  NUM_ZEROES = 4

  option :previous_block
  option :transaction
  option :previous_block_hash, default: proc { previous_block.own_hash if previous_block }
  option :nonce,               default: proc { calc_nonce }
  option :own_hash,            default: proc { hash(full_block(nonce)) }

  class << self
    def create_genesis_block(public_key:, private_key:)
      genesis_transaction = Transaction.new(from: nil, to: public_key, amount: 500_000, private_key: private_key)
      Block.new(previous_block: nil, transaction: genesis_transaction)
    end
  end

  def valid?
    valid_nonce?(nonce) && transaction.valid_signature?
  end

  private

  attr_reader :nonce, :previous_block

  def hash(contents)
    Digest::SHA256.hexdigest(contents)
  end

  def calc_nonce
    nonce = 'CAN YOU SEE THE END?'
    count = 0
    until valid_nonce?(nonce)
      nonce = nonce.next
      count += 1
    end
    nonce
  end

  def valid_nonce?(nonce)
    hash(full_block(nonce)).start_with?('0' * NUM_ZEROES)
  end

  def full_block(nonce)
    [transaction.to_s, previous_block_hash, nonce].compact.join
  end
end
