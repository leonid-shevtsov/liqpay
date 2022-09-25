# frozen_string_literal: true

require 'liqpay/version'
require 'liqpay/request'
require 'liqpay/response'

require 'liqpay/railtie' if defined?(Rails)

# Liqpay implements the LiqPay payment API.
module Liqpay
  LIQPAY_ENDPOINT_URL = 'https://www.liqpay.ua/api/3/checkout'
  LIQPAY_API_VERSION = 3

  # Other actions are not supported
  ACTION_PAY = 'pay'
  ACTION_DONATE = 'paydonate'

  SUPPORTED_CURRENCIES = %w[USD EUR UAH BYN KZT].freeze

  @default_options = {}
  class << self; attr_accessor :default_options; end

  class Exception < StandardError; end
  class InvalidResponse < StandardError; end
end
