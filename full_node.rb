$BC_NODE = :full_node

require "./config/environment"

discovery = Nodes::Discovery::Config.new

client = Nodes::Full::Client.new(discovery: discovery)
server = Nodes::Full::Server.new(client: client)
server.run



