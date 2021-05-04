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
require './lib/context/request'
require './lib/metrics/instruments'
require './lib/metric'

# $stdout.sync = true
LOGGER = Logger.new($stdout)
LOGGER.formatter = proc do |severity, datetime, _, msg|
  {
    level: severity,
    timestamp: datetime.to_s,
    message: msg
  }.to_json + "\n"
  # print "{\"message\": \"#{msg}\"}"
end

case $BC_NODE
when :discovery_node
  require './nodes/discovery/server'
when :full_node
  require './value_objects/owner_peer'
  require './value_objects/public_peer'
  require './lib/pki'
  require './domain/transaction'
  require './domain/block'
  require './domain/blockchain'
  require './services/blockchain'
  require './services/transactions'
  require './services/peers'
  require './nodes/full/client'
  require './nodes/full/server'
end
