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

require_relative '../protocols/exceptions'
require_relative '../protocols/tcp/client'
require_relative '../protocols/tcp/server'
require_relative '../aggregates/peers'
require_relative '../value_objects/peer'
require_relative '../lib/context/request'
require_relative '../lib/metrics/instruments'
require_relative '../lib/metric'

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
  require_relative '../nodes/discovery/server'
when :full_node
  require_relative '../value_objects/owner_peer'
  require_relative '../value_objects/public_peer'
  require_relative '../lib/pki'
  require_relative '../lib/rabbitmq/client'
  require_relative '../domain/transaction'
  require_relative '../domain/block'
  require_relative '../domain/blockchain'
  require_relative '../services/blockchain'
  require_relative '../services/transactions'
  require_relative '../services/peers'
  require_relative '../nodes/full/client'
  require_relative '../nodes/full/server'
end
