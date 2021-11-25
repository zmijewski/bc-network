# frozen_string_literal: true

class Blockchain
  extend Dry::Initializer

  attr_reader :blocks

  option :public_key
  option :private_key
  option :blocks, default: proc { [Block.create_genesis_block(public_key: public_key, private_key: private_key)] }

  def length
    blocks.length
  end

  def add_to_chain(transaction:)
    LOGGER.info("#{Digest::SHA256.hexdigest(transaction.from)} is sending #{transaction.amount} tokens to: #{Digest::SHA256.hexdigest(transaction.to)}")
    Metric.new(
      name: 'new_block',
      properties: {
        from: Digest::SHA256.hexdigest(transaction.from),
        to: Digest::SHA256.hexdigest(transaction.to),
        tokens: transaction.amount
      }
    ).send
    @blocks.push(Block.new(previous_block: blocks.last, transaction: transaction))
  end

  def progenitor
    blocks.first.transaction.to if blocks.first.is_a?(Block)
  end

  def valid?
    blocks.all? { |block| block.is_a?(Block) } &&
      blocks.all?(&:valid?) &&
      blocks.each_cons(2).all? { |a, b| a.own_hash == b.previous_block_hash } &&
      all_spends_valid?
  end

  def all_spends_valid?
    compute_balances do |balances, from, to|
      return false if balances.values_at(from, to).any?(&:negative?)
    end
    true
  end

  def compute_balances
    genesis_transaction = blocks.first.transaction
    balances            = { genesis_transaction.to => genesis_transaction.amount }
    balances.default    = 0
    blocks.drop(1).each do |block|
      from   = block.transaction.from
      to     = block.transaction.to
      amount = block.transaction.amount

      balances[from] -= amount
      balances[to]   += amount

      yield balances, from, to if block_given?
    end
    balances
  end

  def to_s
    blocks.map(&:to_s).join("\n")
  end
end
