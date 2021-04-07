# frozen_string_literal: true

$BC_NODE = :full_node

require './config/environment'

PRIV_KEY, PUB_KEY = PKI.generate_key_pair

discovery = Peer.new(host: 'discovery_node', port: 80)

client = Nodes::Full::Client.new(public_key: PUB_KEY, private_key: PRIV_KEY, discovery: discovery)
server = Nodes::Full::Server.new(client: client)

client.sync_discovery

Thread.new do
  loop do
    sleep(rand(3..5))
    client.peers.each do |other_peer|
      client.gossip_with(other_peer: other_peer)
    end
  end
end

Thread.new do
  loop do
    sleep(rand(10..20)) # waits for server and does some breaks between sending a message
    other_peer = client.peers.to_a.sample
    next unless other_peer && client.ready?

    client.send_money(other_peer: other_peer)
  end
end

server.run
