# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_annotations/version'

Gem::Specification.new do |spec|
  spec.name          = "active_annotations"
  spec.version       = ActiveAnnotations::VERSION
  spec.authors       = ["Michael B. Klein"]
  spec.email         = ["mbklein@gmail.com"]

  spec.summary       = %q{OpenAnnontations + JSON-LD + ActiveRecord}
  spec.description   = %q{See http://www.openannotation.org/spec/core/}
  spec.homepage      = "http://github.com/avalonmediasystem/active_annotations"
  spec.license       = "Apache"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json-ld"
  spec.add_dependency "rdf-vocab"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "engine_cart"
  spec.add_development_dependency "faker"
end
