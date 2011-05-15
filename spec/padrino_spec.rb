require File.expand_path('../spec_helper.rb', __FILE__)

describe "padrino" do
  %w(slim erb haml).each do |engine|
    %w(mongomapper datamapper activerecord mongoid sequel).each do |orm|
      describe "project with #{orm} and #{engine}" do
        attr_reader :engine, :orm, :app, :tmp, :apptmp, :name

        before :all do
          Padrino.clear!
          @engine = engine
          @orm    = orm
          @name   = "app%x" % rand(2**150)
          @tmp    = File.expand_path("../../fixtures/tmp", __FILE__)
          @apptmp = File.join(@tmp, @name)
          ENV['BUNDLE_GEMFILE'] = nil
          FileUtils.mkdir_p(@tmp)
        end

        after :all do
          begin
            FileUtils.rm_rf(apptmp)
            MongoMapper.database = "#{name}_development"
            MongoMapper.database.collections.select { |c| c.name !~ /system/ }.each(&:drop)
            # CouchRest.database!("#{name}_development").delete!
          rescue Exception => e
            puts "#{e.class}: #{e.message}"
          end
        end

        it "should generate a project" do
          out = padrino_gen(:project, "#{name}", "-d=#{orm}", "-e=#{engine}", "--root=#{tmp}", "--dev")
          out.should =~ /Applying '#{orm}'/i
          out.should =~ /Applying '#{engine}'/i
          ENV['BUNDLE_GEMFILE'] = File.join(apptmp, "Gemfile")
        end

        it "should generate an admin" do
          out = padrino_gen(:admin, "--root=#{apptmp}")
          out.should =~ /The admin panel has been mounted/
          if orm !~ /mongo|couch/
            out = padrino(:rake, migrate(orm), "--chdir=#{apptmp}")
            out.should =~ /Rake/i
          end
          replace_seed(apptmp)
          out = padrino(:rake, "seed", "--chdir=#{apptmp}")
          out.should =~ /Ok/i
          # Launch project, with few hacks...
          PADRINO_ROOT.replace(apptmp)
          require File.join(apptmp, '/config/boot.rb')
          @app = Padrino.application
          # We rock
          visit "/admin"
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