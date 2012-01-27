require 'base64'
require 'nokogiri'

module Liqpay
  class Response < BaseOperation
    SUCCESS_STATUSES = %w(success wait_secure)

    attr_reader :encoded_xml, :signature, :xml

    ATTRIBUTES = %w(merchant_id order_id amount currency description status code transaction_id pay_way sender_phone goods_id pays_count)
    %w(merchant_id order_id amount currency description status code transaction_id pay_way sender_phone goods_id pays_count).each do |attr|
      attr_reader attr
    end

    # Amount of payment. MUST match the requested amount
    attr_reader :amount
    # Currency of payment. MUST match the requested currency
    attr_reader :currency
    # Status of payment. One of '
    #   failure 
    #   success
    #   wait_secure - success, but the card wasn't known to the system 
    attr_reader :status
    # Error code
    attr_reader :code
    # LiqPAY's internal transaction ID
    attr_reader :transaction_id
    # Chosen method of payment
    attr_reader :pay_way
    # Payer's phone
    attr_reader :sender_phone

    def initialize(options = {})
      super(options)

      @encoded_xml = options[:operation_xml]
      @signature = options[:signature]

      decode!
    end

    # Returns true, if the transaction was successful
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
