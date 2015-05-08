# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'boost_info/version'

Gem::Specification.new do |spec|
  spec.name          = "boost_info"
  spec.version       = BoostInfo::VERSION
  spec.authors       = ["Igor Vetrov", "Alexander Tsygankov"]
  spec.email         = ["capybarov@gmail.com"]

  spec.summary       = %q{Simple parser for Boost INFO format}
  spec.homepage      = "https://github.com/zenbro/boost_info"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.6"
end
