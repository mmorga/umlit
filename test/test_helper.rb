unless ENV["GUARD"]
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require "umlit"
require "json"
