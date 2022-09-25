# frozen_string_literal: true

require 'base64'
require 'liqpay/base_operation'

module Liqpay
  # Represents a response from the LiqPay API.
  class Response < SignedPayload
    SUCCESS_STATUSES = %w[success wait_secure sandbox].freeze

    ATTRIBUTES = %w[public_key order_id amount currency description type status transaction_id sender_phone].freeze
    %w[public_key order_id description type].each do |attr|
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
    #   sandbox
    attr_reader :status
    # LiqPAY's internal transaction ID
    attr_reader :transaction_id
    # Payer's phone
    attr_reader :sender_phone

    def initialize(params = {}, options = {})
      super(options)

      ATTRIBUTES.each do |attribute|
        instance_variable_set "@#{attribute}", params[attribute]
      end
      @request_signature = params['signature']

      decode!
    end

    # Returns true, if the transaction was successful
    def success?
      SUCCESS_STATUSES.include? status
    end

    def signature_fields
      [amount, currency, public_key, order_id, type, description, status, transaction_id, sender_phone]
    end

    private

    def decode!
      raise Liqpay::InvalidResponse if signature != @request_signature
    end
  end
end
