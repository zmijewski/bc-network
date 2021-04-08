
require 'socket'
require 'dry-initializer'
require 'pry'
require 'json'
require 'set'
require 'concurrent-ruby'
require 'logger'
require 'yaml'
require 'digest'

require './lib/pki'
require './domain/transaction'
require './domain/block'
require './domain/block_chain'

PRIV_KEY, PUB_KEY = ::PKI.generate_key_pair
PRIV_KEY2, PUB_KEY2 = ::PKI.generate_key_pair

blockchain = ::BlockChain.new(public_key: PUB_KEY, private_key: PRIV_KEY)

transaction = ::Transaction.new(
  from: PUB_KEY,
  to: PUB_KEY2,
  amount: 100,
  private_key: PRIV_KEY
)

blockchain.add_to_chain(transaction: transaction)

x = YAML.dump(blockchain)
y = YAML.load(x)

binding.pry
