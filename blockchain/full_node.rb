# frozen_string_literal: true

$BC_NODE = :full_node

require_relative './config/environment'

PRIV_KEY, PUB_KEY = ::PKI.generate_key_pair

discovery  = ::Peer.new(host: 'discovery_node', port: 80)
owner_peer = ::OwnerPeer.new(
  host: IPSocket.getaddress(Socket.gethostname),
  port: 80,
  public_key: PUB_KEY,
  private_key: PRIV_KEY
)

peers_aggregate    = ::Aggregates::Peers.new(owner: owner_peer)
peers_service      = ::Services::Peers.new(peers_aggregate: peers_aggregate)
blockchain_service = ::Services::Blockchain.new

client = Nodes::Full::Client.new(
  peers_service: peers_service,
  blockchain_service: blockchain_service,
  discovery: discovery
)

client.discover

Thread.new do
  loop do
    sleep(rand(3..5))
    client.peers.each do |peer|
      client.gossip(peer: peer)
    end
  end
end

Thread.new do
  i = 0
  while i < 2
    sleep(rand(10..20)) # waits for server and does some breaks between sending a message
    peer = client.peers.to_a.sample
    next unless peer && client.ready?

    client.send_money(peer: peer)
    i += 1
  end
end

server = Nodes::Full::Server.new(
  peers_service: peers_service,
  blockchain_service: blockchain_service,
  discovery: discovery
)
server.run
