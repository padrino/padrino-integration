require File.expand_path('../spec_helper.rb', __FILE__)

describe "padrino" do

  def in_clean_env(&block)
    pid = fork do
      PADRINO_ROOT.replace(apptmp)
      require File.join(@apptmp, '/config/boot.rb')
      @app = Padrino.application
      # Now we can call our block
      Capybara.app = @app
      block.call
    end
    Process.waitpid(pid)
  end

  %w(slim haml erb).each do |engine|
    %w(ohm activerecord minirecord couchrest mongomapper datamapper mongoid).each do |orm|
      next if orm == "ohm" # issue https://github.com/padrino/padrino-framework/issues/1138
      describe "project with #{orm} and #{engine}" do
        attr_reader :engine, :orm, :app, :tmp, :apptmp, :name

        before :all do
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
            Mongo::Connection.new.drop_database("#{name}_development") if orm  =~ /mongo/i
            CouchRest.database!("#{name}_development").delete! if orm  =~ /couch/i &&  !ENV['TRAVIS']
            Ohm.flush if orm =~ /ohm/i
            Padrino.clear!
          rescue Exception => e
            puts "#{e.class}: #{e.message}"
          end
        end

        it "should generate a project" do

          out = padrino_gen(:project, "#{name}", "-d=#{orm}", "-e=#{engine}", "--root=#{tmp}", "--dev")
          out.should =~ /applying.*#{orm}/i
          out.should =~ /applying.*#{engine}/i
          ENV['BUNDLE_GEMFILE'] = File.join(apptmp, "Gemfile")
        end

        it "should generate an admin" do
          out = padrino_gen(:admin, "--root=#{apptmp}")
          out.should =~ /The admin panel has been mounted/
          if orm !~ /mongo|couch|mini|ohm/
            out = padrino(:rake, migrate(orm), "--chdir=#{apptmp}")
            out.should =~ /=> Executing Rake/i
          end
          replace_seed(apptmp)
          out = padrino(:rake, "seed", "--chdir=#{apptmp}")
          out.should =~ /Ok/i
          # Launch project, with few hacks...
          in_clean_env do
            # We rock
            visit "/admin"
            fill_in "email",    :with => "info@padrino.com"
            fill_in "password", :with => "sample"
            click_button "Sign In"
            click_link "Accounts"
            # Editing
            click_link "Edit your profile"
            fill_in "account[name]", :with => "Foo"
            fill_in "account[surname]", :with => "Bar"
            fill_in "account[email]", :with => "info@lipsiasoft.com"
            fill_in "account[password]", :with => "sample"
            fill_in "account[password_confirmation]", :with => "sample"
            click_button "save"
            page.should have_selector ".alert", :text => "account with ID #{current_url.split('/').last} was successfully updated."
            page.should have_field "account_name", :with => "Foo"
            page.should have_field "account_surname", :with => "Bar"
            click_link "Accounts"
            page.should have_selector "td", :text => "Foo"
            page.should have_selector "td", :text => "Bar"
            # New account
            click_link "Accounts"
            click_link "new"
            click_button "save"
            click_button "save" # TODO : NEED TO FIX, flash message issue !!!
            page.should have_selector ".alert", :text => "Couldn't create the account"
            fill_in "account[name]", :with => "Sam"
            fill_in "account[surname]", :with => "Max"
            fill_in "account[email]", :with => "info@sample.com"
            fill_in "account[password]", :with => "sample"
            fill_in "account[role]", :with => "admin"
            fill_in "account[password_confirmation]", :with => "sample"
            click_button "save"
            page.should have_selector ".alert", :text => "Account was successfully created."
            # Check Profile works
            click_link "Edit your profile"
            page.should have_field "account_name", :with => "Foo"
            page.should have_field "account_surname", :with => "Bar"
            # Logout
            click_button "Exit the admin"
            page.should have_css("img[alt*='Padrino']") # TODO : need to refactor
          end

        end

        it "should generate an admin page" do
          ids =[]
          out = padrino_gen(:model, :post, "title:string", "page:string", "--root=#{apptmp}")
          out.should =~ /orms\/#{orm}/i
          if orm !~ /mongo|couch|mini|ohm/
            out = padrino(:rake, migrate(orm), "--chdir=#{apptmp}")
            out.should =~ /=> Executing Rake/i
          end
          out = padrino_gen(:admin_page, :post, "--root=#{apptmp}")
          out.should =~ /admin\/views\/posts/i
          # Launch project, with few hacks...
          in_clean_env do
            visit "/admin"
            fill_in "email",    :with => "info@sample.com"
            fill_in "password", :with => "sample"
            click_button "Sign In"
            # New
            5.times do
              click_link "Posts"
              click_link "new"
              fill_in "post[title]", :with => "Foo"
              fill_in "post[page]", :with => "Bar"
              click_button "save"
              page.should have_selector ".alert", :text => "Post was successfully created."
              ids << current_url.split('/').last
            end
            # Edit
            click_link "Posts"
            find_link("edit-#{ids[0]}").trigger('click')
            fill_in "post[title]", :with => "Padrino"
            fill_in "post[page]", :with => "Is Cool"
            click_button "save"
            page.should have_selector ".alert", :text => "post with ID #{ids[0]} was successfully updated."
            click_link "Posts"
            page.should have_selector "td", :text => "Padrino"
            page.should have_selector "td", :text => "Is Cool"
            # Destroy
            find_link("delete-#{ids[0]}").trigger('click')
            click_button "confirm-delete-#{ids[0]}"
            page.should have_selector ".alert", :text =>  "Post with ID #{ids[0]} was successfully deleted."
            ids.shift # remove id from array
            # Multiple delete
            click_link 'cogs'
            click_link 'select-all'
            click_link 'delete-selected'
            click_button "confirm-delete-selected"
            ids.reverse! if orm  =~ /couchrest/i # WHY ???
            page.should have_selector ".alert", :text =>  "Posts #{ids.join(',')} were successfully deleted."
          end
        end

        it "should detect a new file" do
          controller = "%s::App.controllers do; get '/' do; 'hi'; end; end" % name.capitalize
          in_clean_env do
            visit "/"
            page.status_code.should be 404
            File.open(File.join(apptmp, 'app', 'controllers', 'base.rb'), 'w') { |f| f.write controller }
            Padrino.reload!
            visit "/"
            page.status_code.should be 200
            page.should have_content 'hi'
          end
        end

        it "should reload a file" do
          controller = File.read(File.join(apptmp, 'app', 'controllers', 'base.rb'))
          in_clean_env do
            visit "/"
            page.should have_content 'hi'
            File.open(File.join(apptmp, 'app', 'controllers', 'base.rb'), 'w') { |f| f.write controller.gsub(/hi/, 'hello') }
            Padrino.reload!
            visit "/"
            page.should have_content 'hello'
          end
        end
       end # describe
    end # orm
  end # engine
end # describe
