require 'rubygems' unless defined?(Gem)
require 'date'
require 'fileutils'
require 'bundler/setup'
require 'capybara/dsl'
require 'capybara/rspec'
require 'capybara/poltergeist'

# Require our gems
Bundler.require(:default, :debug, :apps, :padrino)

# Setup globally Padrino logger
Padrino::Logger::Config[:development][:stream] = :null
Padrino::Logger::Config[:development][:log_level] = :debug

module Helpers
  def padrino(command, *args)
    run_bin(padrino_folder('padrino-core/bin/padrino'), command, *args)
  end

  def padrino_gen(command, *args)
    run_bin(padrino_folder('padrino-gen/bin/padrino-gen'), command, *args)
  end

  def run_bin(bin_path, command, *args)
    `#{Gem.ruby} #{bin_path} #{command} #{args.join(" ")}`.strip
  end

  def replace_seed(path)
    File.open("#{path}/db/seeds.rb", "w") do |f| f.puts <<-RUBY.gsub(/^ {8}/, '')
        account = Account.create(
            :email => 'info@padrino.com',
            :password => 'sample',
            :password_confirmation => 'sample',
            :role => 'admin'
        )
        puts 'Ok'
      RUBY
    end
  end

  def migrate(orm)
    case orm.to_sym
      when :activerecord then "ar:migrate"
      when :datamapper   then "dm:migrate"
      when :sequel       then "sq:migrate:up"
      else ""
    end
  end

  def padrino_folder(path)
    @_padrino_path ||= File.expand_path(Bundler.load.specs.find{ |s| s.name == "padrino" }.full_gem_path + '/..')
    File.join(@_padrino_path, path)
  end

  def editing(file, buffer, match=nil, &block)
    buf_was = File.read(file)
    buf_new = match ? buf_was.gsub(match, buffer) : buffer
    File.open(file, "w") { |f| f.puts buf_new }
    sleep 5 # take the time to intercept new changes.
    block.call
  ensure
    File.open(file, "w") { |f| f.puts buf_was }
  end

end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Helpers
  conf.include Capybara::DSL
end
Capybara.default_driver = :poltergeist
