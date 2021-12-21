source 'https://rubygems.org'
# Specify your gem's dependencies in active_annotations.gemspec
gemspec

group :test do
  gem 'rspec_junit_formatter'
end

# BEGIN ENGINE_CART BLOCK
# engine_cart: 1.0.1
# engine_cart stanza: 0.10.0
# the below comes from engine_cart, a gem used to test this Rails engine gem in the context of a Rails app.
file = File.expand_path('Gemfile', ENV['ENGINE_CART_DESTINATION'] || ENV['RAILS_ROOT'] || File.expand_path('.internal_test_app', File.dirname(__FILE__)))
if File.exist?(file)
  begin
    eval_gemfile file
  rescue Bundler::GemfileError => e
    Bundler.ui.warn '[EngineCart] Skipping Rails application dependencies:'
    Bundler.ui.warn e.message
  end
else
  Bundler.ui.warn "[EngineCart] Unable to find test application dependencies in #{file}, using placeholder dependencies"

  if ENV['RAILS_VERSION']
    if ENV['RAILS_VERSION'] == 'edge'
      gem 'rails', github: 'rails/rails'
      ENV['ENGINE_CART_RAILS_OPTIONS'] = '--edge --skip-turbolinks --skip-javascript'
    else
      gem 'rails', ENV['RAILS_VERSION']
      ENV['ENGINE_CART_RAILS_OPTIONS'] = '--skip-turbolinks --skip-javascript'
    end
    case ENV['RAILS_VERSION']
    when /^6.0/
      gem 'sass-rails', '>= 6'
      gem 'webpacker', '~> 4.0'
    when /^5.[12]/
      gem 'sass-rails', '~> 5.0'
      gem 'sprockets', '~> 3.7'
      gem 'thor', '~> 0.20'
    end
  end
end
# END ENGINE_CART BLOCK
