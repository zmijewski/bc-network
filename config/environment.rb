# frozen_string_literal: true

require 'socket'
require 'dry-initializer'
require 'pry'
require 'json'
require 'set'
require 'concurrent-ruby'
require 'logger'
require 'yaml'
require 'digest'

require './protocols/exceptions'
require './protocols/tcp/client'
require './protocols/tcp/server'
require './aggregates/peers'
require './value_objects/peer'

LOGGER = Logger.new($stdout)

case $BC_NODE
when :discovery_node
  require './nodes/discovery/server'
when :full_node
  require './lib/pki'
  require './domain/transaction'
  require './domain/block'
  require './domain/block_chain'
  require './nodes/full/client'
  require './nodes/full/server'
end
