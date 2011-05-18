require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'rspec/core/rake_task'

specs = Dir['./spec/**/*_spec.rb']

specs.each do |spec|
  RSpec::Core::RakeTask.new("spec:#{File.basename(spec, '_spec.rb')}") do |t|
    t.pattern = spec
    t.skip_bundler = true
    t.rspec_opts = %w(-fs --color --fail-fast -d)
    t.rspec_opts << "-l #{ARGV[1]}" if ARGV[1]
  end
end

desc "Run complete application spec suite"
RSpec::Core::RakeTask.new("spec") do |t|
  t.skip_bundler = true
  t.pattern = './spec/**/*_spec.rb'
  t.rspec_opts = %w(-fs --color --fail-fast -d)
  t.rspec_opts << "-l #{ARGV[1]}" if ARGV[1]
end

desc "Launch a single app"
task :launch, :app do |t, args|
  raise "Please specify an app=padrino_basic !" unless args.app
  Bundler.require(:debug, :padrino)
  begin
    app = File.expand_path("../fixtures/single-apps/#{args.app}.rb", __FILE__)
    app_was = File.read(app)
    require app
    Padrino.run!
  ensure
    File.open(app, "w") { |f| f.write app_was }
  end
end

task "Remove *.rbc"
task :rbc do
  Dir["**/*.rbc"].each { |rbc| `rm -rf #{rbc}` }
end