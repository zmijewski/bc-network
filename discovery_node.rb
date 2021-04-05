$BC_NODE = :discovery_node

require "./config/environment"

discovery = Nodes::Discovery::Config.new
server    = Nodes::Discovery::Server.new(config: discovery)
server.run
