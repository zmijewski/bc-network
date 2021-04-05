class Peer
  attr_reader :host, :port

  def initialize(peer)
    peer.transform_keys!(&:to_sym)

    fail PeerAttributeMissingError unless peer[:host] && peer[:port]

    @host = peer[:host]
    @port = peer[:port]
  end

  def to_hash
    { host: host, port: port }
  end

  def eql?(other)
    hash == other.hash
  end

  def hash
    to_hash.hash
  end

  def to_s
    "@#{host}:#{port}"
  end
end

class PeerAttributeMissingError < StandardError; end
