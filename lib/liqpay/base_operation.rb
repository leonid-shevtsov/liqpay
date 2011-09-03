require 'digest/sha1'
require 'base64'

module Liqpay
  class BaseOperation
    attr_accessor :merchant_id, :merchant_signature

    def initialize(options={})
      options.replace(Liqpay.default_options.merge(options))

      @merchant_id = options[:merchant_id]
      @merchant_signature = options[:merchant_signature]
    end

    def signature
      @signature ||= sign(xml, @merchant_signature)
    end

  private
    def sign(xml, signature)
      Base64.encode64(Digest::SHA1.digest(signature + xml + signature)).strip
    end
  end
end
