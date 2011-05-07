require 'rubygems'
require 'test/unit'
require 'webrat'
require 'mechanize'
require 'nokogiri'
require 'rack'
require 'shoulda'
require 'ruby-debug'
require 'date'
require 'mongo_mapper'
require 'couchrest'

class Test::Unit::TestCase
  include Webrat::Methods
  include Webrat::Matchers

  # No idea why we need this but without it response_code is not always recognized
  Webrat::Methods.delegate_to_session :response_code, :response_body

  # This is needed for webrat_steps.rb
  Webrat::Methods.delegate_to_session :response

  # More fast
  Mechanize.html_parser = Nokogiri::HTML

  Webrat.configure do |config|
    config.mode = :mechanize
  end

  def padrino(command, *args)
    run_bin(padrino_folder('padrino-core/bin/padrino'), command, *args)
  end

  def padrino_gen(command, *args)
    run_bin(padrino_folder('padrino-gen/bin/padrino-gen'), command, *args)
  end

  def bundle(command, *args)
    run_bin(File.expand_path('../support/bundle', __FILE__), command, *args)
  end

  def run_bin(bin_path, command, *args)
    log "Executing #{File.basename(bin_path)} #{command} #{args.join(" ")}"
    `#{Gem.ruby} #{bin_path} #{command} #{args.join(" ")}`.strip
  end

  def replace_seed(path)
    File.open("#{path}/db/seeds.rb", "w") do |f| f.puts <<-RUBY
        Account.create(:email => 'info@padrino.com',
                       :password => 'sample',
                       :password_confirmation => 'sample',
                       :role => 'admin')
        puts "Ok"
      RUBY
    end
  end

  def log(message, options={})
    options[:level] = 2 unless options[:level]
    output_method = options[:inline] ? method(:print) : method(:puts)
    prefix = " " * options[:level] unless options[:level].nil? || options[:level] == 1
    output_method.call(prefix + message)
  end

  def migrate(orm)
    case orm.to_sym
      when :activerecord then "ar:migrate"
      when :datamapper   then "dm:migrate"
      when :sequel       then "sq:migrate:auto"
      else ""
    end
  end

  PADRINO_ROOT = ENV["PADRINO_PATH"] unless defined?(PADRINO_ROOT)
  # padrino_folder("padrino-core/bin/padrino") => "/full/path/to/padrino/padrino-core/..."
  def padrino_folder(path)
    File.expand_path(File.join(PADRINO_ROOT, path), __FILE__)
  end
end

module Webrat
  class MechanizeAdapter
    # Suppress warnings
    def mechanize
      @mechanize ||= Mechanize.new
    end
  end

  module Logging
    # Suppress logger
    def logger
      @logger = nil
    end
  end
end