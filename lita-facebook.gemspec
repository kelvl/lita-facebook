Gem::Specification.new do |spec|
  spec.name          = "lita-facebook"
  spec.version       = "0.1.0"
  spec.authors       = ["Kelvin Law"]
  spec.email         = ["calvin18@gmail.com"]
  spec.description   = "Lita Adapter for NodeJS server"
  spec.summary       = "Lita Adapter for NodeJS server"
  spec.homepage      = "https://github.com/kelvl/lita-facebook"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "adapter" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.4"
  spec.add_runtime_dependency "faye-websocket", ">= 0.8.0"
  spec.add_runtime_dependency "eventmachine"
  spec.add_runtime_dependency "multi_json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
