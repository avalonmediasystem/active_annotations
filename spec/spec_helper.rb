$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'engine_cart'

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/.internal_test_app/"
end

EngineCart.load_application!
require 'active_annotations'
require 'faker'
