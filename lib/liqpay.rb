require 'liqpay/version'
require 'liqpay/request'
require 'liqpay/response'

module Liqpay
  API_VERSION = '1.2'
  ENDPOINT_URL = 'https://www.liqpay.com/?do=clickNbuy'
  SUPPORTED_CURRENCIES = %w(UAH USD EUR RUR)

  @default_options = {}
  class << self; attr_accessor :default_options; end

  class Exception < ::Exception; end
  class InvalidResponse < Exception; end
end
