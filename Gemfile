source :rubygems

gem "mechanize"
gem "webrat"
gem "shoulda"

group :apps do
  gem 'rake'
  gem 'thor'
  gem 'rack-flash'
  gem 'thin'
  gem 'mocha'
  gem 'rr'
  gem 'activerecord'
  gem 'couchrest_model'
  gem 'json_pure'
  gem 'data_mapper'
  gem 'bson_ext'
  gem 'mongoid', '2.0.0'
  platforms :mri_18 do
    gem 'SystemTimer'
  end
  gem 'mongo_mapper'
  gem 'mongomatic'
  gem 'json'
  gem 'ohm'
  gem 'ohm-contrib'
  gem 'sequel'
  gem 'haml'
  gem 'erubis', '~>2.6.6' # couchrest require that
  gem 'slim'
  gem 'padrino', :path => ENV['PADRINO_PATH']
end

platforms :mri_18 do
  gem "ruby-debug"
end

platforms :mri_19 do
  gem "ruby-debug19"
end