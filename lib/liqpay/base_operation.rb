require 'digest/sha1'
require 'base64'

module Liqpay
  class BaseOperation
    attr_accessor :public_key, :private_key

    def initialize(options={})
      options.replace(Liqpay.default_options.merge(options))

      @public_key = options[:public_key]
      @private_key = options[:private_key]
    end

    def signature
      @signature ||= sign(signature_fields)
    end

    def signature_fields
      raise NotImplementedError
    end

  private
    def sign(fields)
      Base64.encode64(Digest::SHA1.digest(@private_key + fields.join(''))).strip
    end
  end
end
