require 'liqpay/version'
require 'liqpay/request'
require 'liqpay/response'

require 'liqpay/railtie' if defined?(Rails)

module Liqpay
  LIQPAY_ENDPOINT_URL = 'https://www.liqpay.com/api/pay'
  SUPPORTED_CURRENCIES = %w(UAH USD EUR RUB)

  @default_options = {}
  class << self; attr_accessor :default_options; end

  class Exception < ::Exception; end
  class InvalidResponse < Exception; end
end
