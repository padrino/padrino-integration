require 'spec_helper'

describe "padrino" do
  %w(haml erb slim).each do |engine|
    %w(couchrest mongomapper mongoid activerecord datamapper sequel).each do |orm|
      next if engine == "erb" && orm == "couchrest" # couchrest_models depends from erubis 2.6 (why?) padrino need 2.7!
      describe "project with #{orm} and #{engine}" do
        before :all do
          @engine = engine
          @orm    = orm
          @app    = "app%x" % rand(2**150)
          @tmp    = File.expand_path("../../fixtures/tmp", __FILE__)
          @apptmp = File.join(@tmp, @app)
          FileUtils.mkdir_p(@tmp)
        end

        after :all do
          ENV['BUNDLE_GEMFILE'] = nil
          padrino(:stop, "--chdir=#{@apptmp}")
          kill_match(@app)
          FileUtils.rm_rf(@apptmp)
          MongoMapper.database = "#{@app}_development"
          MongoMapper.database.collections.select { |c| c.name !~ /system/ }.each(&:drop)
          CouchRest.database!("#{@app}_development").delete!
        end

        it "should generate a project" do
          out = padrino_gen(:project, "#{@app}", "-d=#{@orm}", "-e=#{@engine}", "--root=#{@tmp}", "--dev")
          out.should =~ /Applying '#{@orm}'/i
          out.should =~ /Applying '#{@engine}'/i
          ENV['BUNDLE_GEMFILE'] = "#{@apptmp}/Gemfile"
          # out = bundle(:install)
          # out.should =~ /Your bundle is complete/
        end

        it "should generate an admin" do
          out = padrino_gen(:admin, "--root=#{@apptmp}")
          out.should =~ /The admin panel has been mounted/
          if @orm !~ /mongo|couch/
            out = padrino(:rake, migrate(@orm), "--chdir=#{@apptmp}")
            out.should =~ /Rake/i
          end
          replace_seed(@apptmp)
          out = padrino(:rake, "seed", "--chdir=#{@apptmp}")
          out.should =~ /Ok/i
          port = 3000
          while `nc -z -w 1 localhost #{port}` =~ /succeeded/
            port += 10
          end
          out = padrino(:start, "-d", "--chdir=#{@apptmp}", "-p #{port}")
          out.should =~ /server has been daemonized with pid/
          wait_localhost(port)
          header "Host", "localhost" # this is for follow redirects
          visit "http://localhost:#{port}/admin"
          fill_in :email,    :with => "info@padrino.com"
          fill_in :password, :with => "sample"
          click_button "Sign In"
          click_link "Accounts"
          # Editing
          click_button "Edit"
          fill_in "account[name]", :with => "Foo"
          fill_in "account[surname]", :with => "Bar"
          fill_in "account[email]", :with => "info@lipsiasoft.com"
          fill_in "account[password]", :with => "sample"
          fill_in "account[password_confirmation]", :with => "sample"
          click_button "Save"
          body.should have_selector ".notice", :content => "Account was successfully updated."
          body.should have_selector "#account_name", :value => "Foo"
          body.should have_selector "#account_surname", :value => "Bar"
          click_link "Accounts"
          body.should have_selector "td", :content => "Foo"
          body.should have_selector "td", :content => "Bar"
          # New account
          click_link "Accounts"
          click_link "New"
          click_button "Save"
          body.should have_selector ".error"
          fill_in "account[name]", :with => "Sam"
          fill_in "account[surname]", :with => "Max"
          fill_in "account[email]", :with => "info@sample.com"
          fill_in "account[password]", :with => "sample"
          fill_in "account[password_confirmation]", :with => "sample"
          click_button "Save"
          body.should have_selector ".notice", :content => "Account was successfully created."
          # Check Profile works
          click_link "Profile"
          body.should have_selector "#account_name", :value => "Foo"
          body.should have_selector "#account_surname", :value => "Bar"
          click_link "Accounts"
          # TODO: Check Destroy of account
          # TODO: Check: padrino g model Post title:string body:text; padrino g admin_page post
          # Logout
          click_button "Logout"
          body.should have_selector "h2", :content => "Login Box"
        end
      end
    end
  end
end