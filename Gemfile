source "https://rubygems.org"

gemspec

if RUBY_VERSION < "1.9.0"
  gem 'json'
  group :test do
    gem 'minitest'
  end
end

group :development do
  gem 'rake'
  gem 'pry'
  gem 'pry-doc'
end
