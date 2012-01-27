require 'base64'
require 'nokogiri'

module Liqpay
  class Response < BaseOperation
    SUCCESS_STATUSES = %w(success wait_secure)

    attr_reader :encoded_xml, :signature, :xml

    ATTRIBUTES = %w(merchant_id order_id amount currency description status code transaction_id pay_way sender_phone goods_id pays_count)
    ATTRIBUTES.each do |attr|
      attr_reader attr
    end

    def initialize(options = {})
      super(options)

      @encoded_xml = options[:operation_xml]
      @signature = options[:signature]

      decode!
    end

    def success?
      SUCCESS_STATUSES.include? self.status
    end

  private
    def decode!
      @xml = Base64.decode64(@encoded_xml)
      
      if sign(@xml, @merchant_signature) != @signature
        raise Liqpay::InvalidResponse
      end

      doc = Nokogiri.XML(@xml)

      ATTRIBUTES.each do |attr|
        self.instance_variable_set('@'+attr, doc.at(attr).try(:content))
      end
    end
  end
end
