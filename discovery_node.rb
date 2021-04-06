$BC_NODE = :discovery_node

require './config/environment'

discovery_peer = Peer.new(host: 'discovery_node', port: 80)
server         = Nodes::Discovery::Server.new(peer: discovery_peer)
server.run
