# frozen_string_literal: true

require 'digest/sha1'
require 'base64'

module Liqpay
  # Handles signing and verification of LiqPay request/responses
  class SignedPayload
    attr_accessor :public_key, :private_key

    def initialize(options = {})
      options.replace(Liqpay.default_options.merge(options))

      @public_key = options[:public_key]
      @private_key = options[:private_key]
    end

    def signature
      @signature ||= sign(data)
    end

    def data
      raise NotImplementedError
    end

    private

    def sign(data)
      Base64.strict_encode64(Digest::SHA1.digest(@private_key + data + @private_key)).strip
    end
  end
end
