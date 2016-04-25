$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'coveralls'
require 'simplecov'
require 'engine_cart'

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  add_filter "/spec/"
  add_filter "/.internal_test_app/"
end

EngineCart.load_application!
require 'active_annotations'
require 'faker'
