source :rubygems

gem "webrat"
gem "rspec"
gem "rack-test", :require => 'rack/test'

group :apps do
  gem 'haml'
  gem 'erubis', "~> 2.7.0"
  gem 'slim'
  gem 'bcrypt-ruby', :require => 'bcrypt'
  gem 'rake'
  gem 'thor'
  gem 'rack-flash', :require => 'rack/flash'
  gem 'thin'
  gem 'mocha'
  gem 'rr'
  gem 'activerecord', :require => 'active_record'
  gem 'sqlite3'
  # For unkown reason the couchrest_model depends from railties wich depepends from actionpack wich load rails
  # and a lot of unuseful stuff BUT needs erubis '2.6.6' wich is not compatible wth padrino/tilt/sinatra and the world
  # gem 'couchrest_model'
  gem 'json_pure'
  gem 'data_mapper'
  gem 'dm-sqlite-adapter'
  gem 'bson_ext', :require => 'mongo'
  gem 'mongoid', '2.0.0'
  platforms :mri_18 do
    gem 'SystemTimer', :require => 'system_timer'
  end
  gem 'mongo_mapper'
  gem 'mongomatic'
  gem 'json'
  gem 'ohm'
  gem 'ohm-contrib', :require => 'ohm/contrib'
  gem 'sequel'
  gem 'mime-types', :require => 'mime/types'

  if ENV['PADRINO_PATH']
    gem 'padrino', :path => ENV['PADRINO_PATH']
  else
    gem 'padrino', :git => "git://github.com/padrino/padrino-framework.git"
  end
end

group :debug do
  platform :mri_18 do
    gem 'ruby-debug'
  end
  platform :mri_19 do
    gem 'ruby-debug19'
  end
end