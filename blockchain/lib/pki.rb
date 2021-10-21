# frozen_string_literal: true

require 'openssl'
require 'base64'

class PKI
  class << self
    def generate_key_pair
      key_pair = OpenSSL::PKey::RSA.new(2048)
      [key_pair.export, key_pair.public_key.export]
    end

    def sign(plaintext:, raw_private_key:)
      private_key = OpenSSL::PKey::RSA.new(raw_private_key)
      Base64.encode64(private_key.private_encrypt(plaintext))
    end

    def plaintext(ciphertext:, raw_public_key:)
      public_key = OpenSSL::PKey::RSA.new(raw_public_key)
      public_key.public_decrypt(Base64.decode64(ciphertext))
    end

    def valid_signature?(message:, ciphertext:, public_key:)
      message == plaintext(ciphertext: ciphertext, raw_public_key: public_key)
    end
  end
end
