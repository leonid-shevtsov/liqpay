require 'liqpay/liqpay_helper'

module Liqpay
  class Railtie < Rails::Railtie
    initializer 'liqpay.view_helpers' do |app|
      ActionView::Base.send :include, Liqpay::LiqpayHelper 
    end
  end
end
