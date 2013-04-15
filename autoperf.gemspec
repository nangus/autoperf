# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'autoperf/version'

Gem::Specification.new do |s|
  s.name        = "autoperf"
  s.version     = Autoperf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine", "Ilya Grigorik"]
  s.email       = ["joshua@mervine.net", "excluded"]
  s.homepage    = "http://www.rubyops.net/gems/autoperf"
  s.summary     = "Autoperf (w/ HTTPerf.rb)"
  s.description = "Autoperf is a ruby driver for httperf, designed to help you automate load and performance testing of any web application - for a single end point, or through log replay."

  s.add_development_dependency "rake"

  s.add_dependency "httperfrb", ">=0.3.11"
  s.add_dependency "ruport"

  s.files        = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w(README.md Gemfile)
  s.require_path = 'lib'
  s.bindir       = 'bin'
  s.executables << 'autoperf'
  s.executables << 'make_replay_log'
end
