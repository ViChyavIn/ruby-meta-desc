# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'metadesc/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-meta-desc'
  spec.version       = Rack::MetaDesc::VERSION
  spec.authors       = ['Nikita Ivanov']

  spec.summary       = "#{spec.name}-#{spec.version}"
  spec.homepage      = 'https://github.com/ViChyavIn/ruby-meta-desk'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rack-test', '~> 0.6'
end
