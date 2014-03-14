require 'base64'
require 'liqpay/base_operation'

module Liqpay
  class Request < BaseOperation
    # REQUIRED Amount of payment (Float), in :currency
    attr_accessor :amount
    # REQUIRED Currency of payment - one of `Liqpay::SUPPORTED_CURRENCIES`
    attr_accessor :currency
    # REQUIRED Description to be displayed to the user
    attr_accessor :description
    # RECOMMENDED Arbitrary but unique ID (May be REQUIRED by LiqPay configuration)
    attr_accessor :order_id
    # RECOMMENDED URL that the user will be redirected to after payment
    attr_accessor :result_url
    # RECOMMENDED URL that'll receive the order details in the background.
    attr_accessor :server_url
    # OPTIONAL type of payment = either `buy` (the default) or `donate`
    attr_accessor :type
    # OPTIONAL UI language - `ru` or `en`
    attr_accessor :language

    def initialize(options={})
      super(options)

      @amount = options[:amount]
      @currency = options[:currency]
      @description = options[:description]
      @order_id = options[:order_id]
      @result_url = options[:result_url]
      @server_url = options[:server_url]
      @type = options[:type]
      @language = options[:language]
      @kamikaze = options[:kamikaze]
    end

    def signature_fields
      [amount, currency, public_key, order_id, type, description, result_url, server_url]
    end

    def form_fields
      validate! unless @kamikaze
      {
        public_key: public_key,
        amount: amount,
        currency: currency,
        description: description,
        order_id: order_id,
        result_url: result_url,
        server_url: server_url,
        type: type,
        signature: signature,
        language: language
      }.reject{|k,v| v.nil?}
    end

  private
    def validate!
      %w(public_key amount currency description).each do |required_field|
        raise Liqpay::Exception.new(required_field + ' is a required field') unless self.send(required_field).to_s != ''
      end

      raise Liqpay::Exception.new('currency must be one of '+Liqpay::SUPPORTED_CURRENCIES.join(', ')) unless Liqpay::SUPPORTED_CURRENCIES.include?(currency)

      begin
        self.amount = Float(self.amount)
      rescue ArgumentError, TypeError
        raise Liqpay::Exception.new('amount must be a number')
      end

      raise Liqpay::Exception.new('amount must be rounded to 2 decimal digits') unless self.amount.round(2) == self.amount

      raise Liqpay::Exception.new('amount must be more than 0.01') unless amount > 0.01
    end
  end
end
