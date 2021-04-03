require "socket"
require "pry"
require "json"
require "set"
require "concurrent-ruby"

require "nodes/discovery/config.rb"
require "nodes/discovery/server.rb"

discovery = Nodes::Discovery::Config.new
server    = Nodes::Discovery::Server.new(config: discovery)
server.run

