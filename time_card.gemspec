# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'time_card/version'

Gem::Specification.new do |spec|
  spec.name          = 'time_card'
  spec.version       = TimeCard::VERSION
  spec.authors       = ['Angel Balcarcel']
  spec.email         = ['abalcarc@thoughtworks.com']
  spec.summary       = %q{Initiative buckets from Mingle for OTL}
  spec.description   = %q{An application for summarizing the work for a specified date range in Mingle by initiative buckets for OTL}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 4.1.4'
  spec.add_dependency 'pg', '~> 0.17.1'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
end
