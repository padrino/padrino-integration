source :rubygems

gem 'rake'
gem 'nokogiri'
gem 'webrat'
gem 'capybara'
gem 'capybara-webkit'
gem 'poltergeist'
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
  gem 'bson_ext', :require => 'mongo'
  gem 'sequel'
  gem 'mongoid', RUBY_VERSION >= '1.9' ? '>=3.0' : '~>2.0'
  gem 'SystemTimer', :require => 'system_timer', :platforms => :mri_18
  gem 'mongo_mapper'
  gem 'mongomatic'
  gem 'ohm'
  gem 'mime-types',  :require => 'mime/types'
end

group :padrino do
  if ENV['PADRINO_PATH']
    puts "\e[33mUsing padrino from: #{ENV['PADRINO_PATH']}\e[0m"
    gem 'padrino', :path => ENV['PADRINO_PATH']
  else
    gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git"
  end
end
