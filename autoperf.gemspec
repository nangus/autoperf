# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'autoperf'

Gem::Specification.new do |s|
  s.name        = "autoperf"
  s.version     = Autoperf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine", "Ilya Grigorik"]
  s.email       = ["joshua@mervine.net", "ilya@igvita.com"]
  s.homepage    = "http://www.rubyops.net/gems/autoperf-httperfrb"
  s.summary     = "Autoperf (w/ HTTPerf.rb)"
  s.description = "Autoperf is a ruby driver for httperf, designed to help you automate load and performance testing of any web application - for a single end point, or through log replay.

This has been refactored from the original -- https://github.com/igrigorik/autoperf -- to include HTTPerf.rb -- http://rubyops.net/gems/httperfrb -- as a simplification."

  s.add_dependency "httperfrb", ">=0.3.11"
 
  s.files        = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w(README.md HISTORY.md Gemfile)
  s.require_path = 'lib'
  s.bindir       = 'bin'
end
