# frozen_string_literal: true

require 'socket'
require 'dry-initializer'
require 'pry'
require 'json'
require 'set'
require 'concurrent-ruby'
require 'logger'

require './value_objects/peer'
require './protocols/tcp'

LOGGER = Logger.new($stdout)

case $BC_NODE
when :discovery_node
  require './nodes/discovery/config'
  require './nodes/discovery/server'
when :full_node
  require './nodes/discovery/config'
  require './nodes/full/client'
  require './nodes/full/server'
end
