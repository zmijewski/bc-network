# frozen_string_literal: true

class PublicPeer < Peer
  attr_reader :public_key

  def initialize(peer)
    super

    raise PublicPeerAttributeMissingError unless peer[:public_key]

    @public_key  = peer[:public_key]
  end
end

class PublicPeerAttributeMissingError < StandardError; end
