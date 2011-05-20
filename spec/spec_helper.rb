require 'rubygems' unless defined?(Gem)
require 'date'
require 'fileutils'
require 'bundler/setup'

# Require our gems
Bundler.require(:default, :debug, :apps, :padrino)

# Setup globally Padrino logger
Padrino::Logger::Config[:development][:stream] = :null

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
        Account.create(:email => 'info@padrino.com',
                       :password => 'sample',
                       :password_confirmation => 'sample',
                       :role => 'admin')
        puts "Ok"
      RUBY
    end
  end

  def migrate(orm)
    case orm.to_sym
      when :activerecord then "ar:migrate"
      when :datamapper   then "dm:migrate"
      when :sequel       then "sq:migrate:auto"
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

  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end
end

Webrat.configure { |config| config.mode = :rack }

# No idea why we need this but without it response_code is not always recognized
Webrat::Methods.delegate_to_session :response_code, :response_body

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
  conf.include Webrat::Methods
  conf.include Webrat::Matchers
  conf.include Helpers
end

module Webrat
  # Disable logging
  module Logging
    def logger
      @logger = nil
    end
  end

  # Follow redirects
  class Session
    def current_host
      URI.parse(current_url).host || @custom_headers["Host"] || default_current_host
    end

    def default_current_host
      adapter.class==Webrat::RackAdapter ? "example.org" : "www.example.com"
    end
  end
end

# Clear ObjectSpace
module ObjectSpace
  extend self

  def clear!
    @_object_space_was ||= ObjectSpace.classes
    (ObjectSpace.classes - @_object_space_was).each { |object| Padrino::Reloader.remove_constant(object) }
    Padrino::Reloader.exclude_constants.clear
    Padrino::Reloader.include_constants.clear
  end
end

# Don't tell me why but on 1.9.2 happen this:
#
#   NameError Exception: uninitialized constant Sequel::Plugins::ValidationHelpers::ClassMethods
#   # => true
#   Sequel::Plugins::ValidationHelpers.const_defined?("ClassMethods")
#
# then I found:
#
#   # => Mongoid::Extensions::Object::Conversions::ClassMethods
#   Sequel::Plugins::ValidationHelpers.send(:eval, "ClassMethods")
#
# and this didn't work:
#
#   # => NameError Exception: constant Sequel::Plugins::ValidationHelpers::ClassMethods not defined
#   Sequel::Plugins::ValidationHelpers.send(:remove_const, "ClassMethods")
#
module Sequel::Plugins::ValidationHelpers
  module ClassMethods; end
end
sequel_path = Bundler.load.specs.find{ |s| s.name == "sequel" }.full_gem_path
load File.join(sequel_path, 'lib/sequel/plugins/validation_helpers.rb')