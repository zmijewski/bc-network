# frozen_string_literal: true

require 'digest'

class Transaction
  extend Dry::Initializer

  attr_reader :from, :to, :amount

  option :from
  option :to
  option :amount
  option :private_key
  option :signature, default: proc { PKI.sign(plaintext: message, raw_private_key: private_key) }
  option :correlation_id, default: proc { "#{SecureRandom.uuid}-#{Time.new.utc.strftime '%Y%m%d'}" }

  def valid_signature?
    return true if genesis_transaction?

    PKI.valid_signature?(message: message, ciphertext: signature, public_key: from)
  end

  def genesis_transaction?
    from.nil?
  end

  def message
    Digest::SHA256.hexdigest([from, to, amount, correlation_id].join)
  end

  def to_s
    message
  end
end
