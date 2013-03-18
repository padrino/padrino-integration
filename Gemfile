source 'https://rubygems.org'

gem 'rake'
gem 'nokogiri'
gem 'webrat'
gem 'capybara'
gem 'poltergeist'#, '~> 1.0.2'
gem 'rspec'
gem 'rack-test', :require => 'rack/test'

group :apps do
  gem 'haml'
  gem 'erubis', '~> 2.7.0'
  gem 'slim'
  gem 'bcrypt-ruby', :require => 'bcrypt'
  gem 'thor'
  gem 'sinatra-flash', :require => 'sinatra/flash'
  gem 'thin'
  gem 'rr'
  gem 'mini_record'
  gem 'activerecord', :require => 'active_record'
  gem 'sqlite3'
  gem 'couchrest_model'
  gem 'json_pure'
  gem 'dm-aggregates'
  gem 'dm-constraints'
  gem 'dm-core'
  gem 'dm-migrations'
  gem 'dm-timestamps'
  gem 'dm-validations'
  gem 'dm-sqlite-adapter'
  gem 'dm-types'
  gem 'sequel'
  gem 'mongoid', RUBY_VERSION >= '1.9' ? '~>3.0.0' : '~>2.0'
  gem 'SystemTimer', :require => 'system_timer', :platforms => :mri_18
  # gem 'bson_ext', :require => 'mongo'
  gem 'mongo_mapper'
  gem 'ohm'
  gem 'mime-types',  :require => 'mime/types'
end

group :padrino do
  if ENV['PADRINO_PATH']
    puts "\e[33mUsing padrino from: #{ENV['PADRINO_PATH']}\e[0m"
    gem 'padrino', :path => ENV['PADRINO_PATH']
  else
    gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git", :branch => "super-admin"
  end
end
