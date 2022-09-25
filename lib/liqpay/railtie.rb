# frozen_string_literal: true

require 'liqpay/liqpay_helper'

module Liqpay
  # Rails integration for the LiqPay view helpers
  class Railtie < Rails::Railtie
    initializer 'liqpay.view_helpers' do |_app|
      ActionView::Base.include Liqpay::LiqpayHelper
    end
  end
end
