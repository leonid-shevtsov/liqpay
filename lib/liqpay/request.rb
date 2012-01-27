require 'base64'

module Liqpay
  class Request < BaseOperation
    # REQUIRED Amount of payment (Float), in :currency
    attr_accessor :amount
    # REQUIRED Currency of payment - one of `Liqpay::SUPPORTED_CURRENCIES`
    attr_accessor :currency
    # REQUIRED Arbitrary but unique ID
    attr_accessor :order_id
    # RECOMMENDED URL that the user will be redirected to after payment
    attr_accessor :result_url
    # RECOMMENDED URL that'll receive the order details in the background.
    attr_accessor :server_url
    # RECOMMENDED Description to be displayed to the user
    attr_accessor :description
    # Phone number to be suggested to the user
    #
    # LiqPAY requires users to provide a phone number before payment.
    # If you know the user's phone number, you can provide it so he
    # doesn't have to enter it manually.
    attr_accessor :default_phone
    # Method of payment. One or more (comma-separated) of:
    #   card - by card
    #   liqpay - by liqpay account
    attr_accessor :pay_way

    attr_accessor :exp_time
    attr_accessor :goods_id

    def initialize(options={})
      super(options)
      
      @result_url = options[:result_url]
      @server_url = options[:server_url]
      @order_id = options[:order_id]
      @amount = options[:amount]
      @currency = options[:currency]
      @description = options[:description]
      @default_phone = options[:default_phone]
      @pay_way = options[:pay_way]
      @kamikaze = options[:kamikaze]
    end

    def encoded_xml
      @encoded_xml ||= encode(xml)
    end

    def xml
      @xml ||= make_xml
    end


  private
    def encode(xml)
      Base64.encode64(xml).gsub(/\s/,'')
    end

    def make_xml
      validate! unless @kamikaze
      Nokogiri::XML::Builder.new { |xml|
        xml.request {
          xml.version Liqpay::LIQBUY_API_VERSION
          xml.merchant_id merchant_id
          xml.result_url result_url
          xml.server_url server_url
          xml.order_id order_id
          xml.amount "%0.2f" % amount
          xml.currency currency
          xml.description description
          xml.default_phone default_phone
          xml.pay_way pay_way.is_a?(Array) ? pay_way.join(',') : pay_way
        }
      }.to_xml
    end

    def validate!

      %w(merchant_id merchant_signature currency amount order_id).each do |required_field|
        raise Liqpay::Exception.new(required_field + ' is a required field') unless self.send(required_field).to_s != ''
      end

      raise Liqpay::Exception.new('currency must be one of '+Liqpay::SUPPORTED_CURRENCIES.join(', ')) unless Liqpay::SUPPORTED_CURRENCIES.include?(currency)

      begin
        self.amount = Float(self.amount)
      rescue ArgumentError, TypeError
        raise Liqpay::Exception.new('amount must be a number')
      end

      raise Liqpay::Exception.new('goods_id must only contain digits') unless goods_id.to_s =~ /\A\d*\Z/

      raise Liqpay::Exception.new('amount must be more than 0.01') unless amount > 0.01
    end
  end
end
