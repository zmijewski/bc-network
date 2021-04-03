require "socket"
require "pry"
require "json"
require "set"
require "concurrent-ruby"

require "nodes/discovery/config.rb"

require "nodes/full/client.rb"
require "nodes/full/server.rb"

discovery = Nodes::Discovery::Config.new

client = Nodes::Full::Client.new(discovery: discovery)
server = Nodes::Full::Server.new(client: client)
server.run

