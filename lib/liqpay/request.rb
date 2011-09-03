require 'base64'

module Liqpay
  class Request < BaseOperation
    attr_accessor :result_url, :server_url, :order_id, :amount, :currency, :description, :default_phone, :pay_way, :goods_id, :exp_time

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
          xml.version Liqpay::API_VERSION
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
