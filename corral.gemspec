$:.push File.expand_path("../lib", __FILE__)

require "corral/version"
Gem::Specification.new do |s|
  s.name          = "corral_acl"
  s.version       = Corral::VERSION
  s.authors       = ["Elliot Speck (Arcaire)"]
  s.email         = ["rubygems@elliot.pro"]
  s.homepage      = "https://github.com/Arcaire/corral"
  s.summary       = "Yet another opinionated ACL framework."
  s.description   = "Yet another opinionated ACL framework."
  s.license       = "MIT"

  s.files         = `git ls-files`.split($/)
  s.require_paths = ["lib"]
  s.add_runtime_dependency "rails", "~> 5.0"
  s.add_development_dependency "rspec"
end
