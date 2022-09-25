# frozen_string_literal: true

require_relative 'lib/liqpay/version'

Gem::Specification.new do |s|
  s.name        = 'liqpay'
  s.version     = Liqpay::VERSION
  s.authors     = ['Leonid Shevtsov']
  s.email       = ['leonid@shevtsov.me']
  s.homepage    = 'https://github.com/leonid-shevtsov/liqpay'
  s.summary     = 'LiqPAY billing API implementation in Ruby'
  s.description = 'LiqPAY billing API implementation in Ruby'
  s.required_ruby_version = '>= 2.7.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
