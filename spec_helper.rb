require 'rubygems'
require 'rspec'
require 'webrat'
require 'mechanize'
require 'nokogiri'
require 'rack'
require 'ruby-debug'
require 'date'
require 'mongo_mapper'
require 'couchrest'
require 'fileutils'

ENV['PADRINO_PATH'] ||= "/src/padrino-framework"

module Helpers
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

  def wait_localhost(port=3000)
    timeout = 30
    while `nc -z -w 1 localhost #{port}` !~ /succeeded/
      timeout -= 1
      sleep 1
      break if timeout == 0
    end
    sleep 5
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
    File.expand_path(File.join(ENV['PADRINO_PATH'], path), __FILE__)
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

  def kill_match(name)
    pids = `ps -ef | grep -vE "^USER|grep|killmatch" | grep "#{name}" | awk '{print $2}'`.chomp.split("\n")
    pids.each { |pid| `kill -9 #{pid}`  }
  end

  def method_missing(name, *args, &block)
    if response && response.respond_to?(name)
      response.send(name, *args, &block)
    else
      super(name, *args, &block)
    end
  end
end

# No idea why we need this but without it response_code is not always recognized
Webrat::Methods.delegate_to_session :response_code, :response_body

# This is needed for webrat_steps.rb
Webrat::Methods.delegate_to_session :response

# More fast
Mechanize.html_parser = Nokogiri::HTML

Webrat.configure do |config|
  config.mode = :mechanize
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

RSpec.configure do |conf|
  conf.include Webrat::Methods
  conf.include Webrat::Matchers
  conf.include Helpers
end