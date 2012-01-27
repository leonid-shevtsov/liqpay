require 'liqpay/version'
require 'liqpay/request'
require 'liqpay/response'

require 'liqpay/railtie' if defined?(Rails)

module Liqpay
  LIQBUY_API_VERSION = '1.2'
  LIQBUY_ENDPOINT_URL = 'https://www.liqpay.com/?do=clickNbuy'
  SUPPORTED_CURRENCIES = %w(UAH USD EUR RUR)

  @default_options = {}
  class << self; attr_accessor :default_options; end

  class Exception < ::Exception; end
  class InvalidResponse < Exception; end
end
