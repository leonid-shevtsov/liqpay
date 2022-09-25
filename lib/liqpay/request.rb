# frozen_string_literal: true

require 'base64'
require 'liqpay/base_operation'

module Liqpay
  # Represends a request to the LiqPay API
  class Request < SignedPayload
    SIGNATURE_FIELDS = %i[amount currency public_key order_id type description result_url server_url].freeze
    REQUEST_FIELDS = (SIGNATURE_FIELDS +  %i[language sandbox]).freeze
    FORM_FIELDS = (REQUEST_FIELDS + %i[signature]).freeze

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
    # OPTIONAL test mode (1 - ON)
    attr_accessor :sandbox

    def initialize(options = {})
      super(options)

      REQUEST_FIELDS.each { |field| send("#{field}=", options[field]) }
      @kamikaze = options[:kamikaze]
    end

    def signature_fields
      SIGNATURE_FIELDS.map { |field| send(field) }
    end

    def form_fields
      validate! unless @kamikaze

      FORM_FIELDS.map { |field| [field, send(field)] }.to_h.reject { |_k, v| v.nil? }
    end

    private

    def validate!
      validate_required_fields!
      validate_currency!
      validate_amount!
    end

    def validate_required_fields!
      %w[public_key amount currency description].each do |required_field|
        raise Liqpay::Exception, "#{required_field} is a required field" unless send(required_field).to_s != ''
      end
    end

    def validate_currency!
      return if Liqpay::SUPPORTED_CURRENCIES.include?(currency)

      raise Liqpay::Exception, "currency must be one of #{Liqpay::SUPPORTED_CURRENCIES.join(', ')}"
    end

    def validate_amount!
      begin
        self.amount = Float(amount)
      rescue ArgumentError, TypeError
        raise Liqpay::Exception, 'amount must be a number'
      end

      raise Liqpay::Exception, 'amount must be rounded to 2 decimal digits' unless amount.round(2) == amount

      raise Liqpay::Exception, 'amount must be more than 0.01' unless amount > 0.01
    end
  end
end
