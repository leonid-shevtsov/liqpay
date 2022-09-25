# frozen_string_literal: true

require 'liqpay/version'
require 'liqpay/request'
require 'liqpay/response'

require 'liqpay/railtie' if defined?(Rails)

# Liqpay implements the LiqPay payment API.
module Liqpay
  LIQPAY_ENDPOINT_URL = 'https://www.liqpay.com/api/pay'
  SUPPORTED_CURRENCIES = %w[UAH USD EUR RUB].freeze

  @default_options = {}
  class << self; attr_accessor :default_options; end

  class Exception < StandardError; end
  class InvalidResponse < StandardError; end
end
