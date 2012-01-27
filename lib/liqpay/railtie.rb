require 'liqpay/liqpay_helper'

module Liqpay
  class Railtie < Rails::Railtie
    ActionView::Base.send :include, Liqpay::LiqpayHelper 
  end
end
