$BC_NODE = :full_node

require './config/environment'

discovery = Nodes::Discovery::Config.new

client = Nodes::Full::Client.new(discovery: discovery)
server = Nodes::Full::Server.new(client: client)

client.sync_discovery

Thread.new do
  loop do
    sleep(rand(3..5)) # waits for server and does some breaks between sending a message
    other_peer = client.peers.to_a.sample
    next unless other_peer

    client.gossip_with(other_peer: other_peer)
  end
end

server.run
