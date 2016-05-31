# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sifi_api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Brandon Aaron"]
  gem.email         = ["brandon@simpli.fi"]
  gem.description   = ""
  gem.summary       = "Ruby wrapper for the Simpli.fi API"
  gem.homepage      = "http://simpli.fi"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "sifiapi"
  gem.require_paths = ["lib"]
  gem.version = SifiApi::VERSION::STRING

  gem.add_dependency 'faraday', '~> 0.9'
  gem.add_dependency 'multi_json', '~> 1.3'
  gem.add_dependency 'activesupport', '~> 4.2.6'
  gem.add_dependency 'i18n', '~> 0.7.0'
end
