require 'rubygems' unless defined?(Gem)
require 'bundler'; Bundler.setup
require 'rspec/core/rake_task'

specs = Dir['./spec/**/*_spec.rb']

specs.each do |spec|
  RSpec::Core::RakeTask.new("spec:#{File.basename(spec, '_spec.rb')}") do |t|
    t.pattern = spec
    t.skip_bundler = true
    t.rspec_opts = %w(-fs --color)
  end
end

desc "Run complete application spec suite"
RSpec::Core::RakeTask.new("spec") do |t|
  t.skip_bundler = true
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w(-fs --color)
end