# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "liqpay/version"

Gem::Specification.new do |s|
  s.name        = "liqpay"
  s.version     = Liqpay::VERSION
  s.authors     = ["Leonid Shevtsov"]
  s.email       = ["leonid@shevtsov.me"]
  s.homepage    = "https://github.com/leonid-shevtsov/liqpay"
  s.summary     = %q{LiqPAY billing API implementation in Ruby}
  s.description = %q{LiqPAY billing API implementation in Ruby}

  s.add_dependency 'nokogiri'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
