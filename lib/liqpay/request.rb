# frozen_string_literal: true

require 'base64'
require 'liqpay/signed_payload'

module Liqpay
  # Represends a request to the LiqPay API
  class Request < SignedPayload
    REQUIRED_FIELDS = %i[public_key amount currency description order_id action].freeze
    OPTIONAL_FIELDS = %i[result_url server_url].freeze
    REQUEST_FIELDS = (REQUIRED_FIELDS + OPTIONAL_FIELDS + %i[version]).freeze

    # REQUIRED Amount of payment (Float), in :currency
    attr_accessor :amount
    # REQUIRED Currency of payment - one of `Liqpay::SUPPORTED_CURRENCIES`
    attr_accessor :currency
    # REQUIRED Description to be displayed to the user
    attr_accessor :description
    # REQUIRED Arbitrary but unique ID
    attr_accessor :order_id
    # REQUIRED  = either Liqpay::ACTION_PAY or Liqpay::ACTION_DONATE
    attr_accessor :action
    # RECOMMENDED URL that the user will be redirected to after payment
    attr_accessor :result_url
    # RECOMMENDED URL that'll receive the order details in the background.
    attr_accessor :server_url

    def initialize(options = {})
      super(options)

      (REQUIRED_FIELDS + OPTIONAL_FIELDS).each { |field| send("#{field}=", options[field]) }
      @action ||= Liqpay::ACTION_PAY

      @kamikaze = options[:kamikaze]
    end

    def version
      Liqpay::LIQPAY_API_VERSION
    end

    def data
      json_data = REQUEST_FIELDS
                  .map { |field| [field, send(field)] }
                  .to_h
                  .reject { |_k, v| v.nil? }
                  .transform_values(&:to_s)
      puts JSON.dump(json_data)
      @data ||= Base64.strict_encode64(JSON.dump(json_data)).strip
    end

    def form_fields
      validate! unless @kamikaze
      { data: data, signature: signature }
    end

    private

    def validate!
      validate_required_fields!
      validate_currency!
      validate_amount!
    end

    def validate_required_fields!
      REQUIRED_FIELDS.each do |required_field|
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
