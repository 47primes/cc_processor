# -*- encoding: utf-8 -*-
$:.unshift File.expand_path("../lib", __FILE__)
require "cc_processor/version"

Gem::Specification.new do |s|
  s.name          = "cc_processor"
  s.description   = "Basic Credit Card Processor"
  s.authors       = ["Mike Bradford"]
  s.email         = ["mbradford@47primes.com"]
  s.version       = CCProcessor::VERSION
  s.platform      = Gem::Platform::RUBY

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.executables   = ["cc_processor"]
  
  s.add_dependency "activerecord", "~> 4.2"
  s.add_dependency "sqlite3", "~> 1.3"

  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "database_cleaner", "~> 1.0"
end
