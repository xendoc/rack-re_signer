# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/re_signer/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-re_signer"
  spec.version       = Rack::ReSigner::VERSION
  spec.authors       = ["xendoc"]
  spec.email         = ["xendoc@users.noreply.github.com"]

  spec.summary       = %q{re-sign proxy for OAuth2 ResourceOwnerPasswordCredential and RefreshToken}
  spec.description   = %q{re-sign proxy for OAuth2 ResourceOwnerPasswordCredential and RefreshToken}
  spec.homepage      = "https://github.com/xendoc/rack-re_signer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", ">= 1.1"

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec', '~> 2.7'
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-bundler"
end
