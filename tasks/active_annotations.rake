require 'engine_cart/rake_task'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern =  'spec/**/*_spec.rb'
end

desc "Run test suite"
task :ci => ['engine_cart:generate'] do
  Rake::Task['spec'].invoke
end
