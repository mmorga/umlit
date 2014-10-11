source 'https://rubygems.org'

# Nice testing tools
group :development, :test do
  gem 'rubocop'

  # Guard gems for automatic testing
  gem "guard"
  gem "guard-minitest"
  gem "guard-bundler"
  gem "guard-rubocop"
  gem "growl"

  # Using Pry
  gem "pry"
  gem 'pry-byebug', platforms: [:mri_20, :mri_21]
  gem 'pry-debugger', platforms: [:mri_19]
end

group :test do
  gem 'simplecov', require: false
end

# Specify your gem's dependencies in umlit2.gemspec
gemspec
