# frozen_string_literal: true

class OwnerPeer < Peer
  attr_reader :public_key, :private_key

  def initialize(peer)
    super

    raise OwnerPeerAttributeMissingError unless peer[:public_key] && peer[:private_key]

    @public_key  = peer[:public_key]
    @private_key = peer[:private_key]
  end
end

class OwnerPeerAttributeMissingError < StandardError; end
