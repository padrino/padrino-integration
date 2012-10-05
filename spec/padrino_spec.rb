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
    %w(sequel ohm activerecord mini_record couchrest mongomapper datamapper mongoid).each do |orm|
      next if orm == 'couchrest' && engine == "erb"

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
            CouchRest.database!("#{name}_development").delete! unless ENV['TRAVIS']
            Ohm.flush
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
            click_link "user-menu"
            click_link "user-profile"
            fill_in "account[name]", :with => "Foo"
            fill_in "account[surname]", :with => "Bar"
            fill_in "account[email]", :with => "info@lipsiasoft.com"
            fill_in "account[password]", :with => "sample"
            fill_in "account[password_confirmation]", :with => "sample"
            click_button "Save"
            page.should have_selector ".notice", :content => "Account was successfully updated."
            page.should have_selector "#account_name", :value => "Foo"
            page.should have_selector "#account_surname", :value => "Bar"
            sleep 0.5
            click_link 'padrino-modal-close'
            click_link "Accounts"
            page.should have_selector "td", :content => "Foo"
            page.should have_selector "td", :content => "Bar"
            # New account
            click_link "Accounts"
            click_link "new"
            click_button "Save"
            page.should have_selector "#field-errors"
            sleep 0.5
            click_link 'padrino-modal-close'
            fill_in "account[name]", :with => "Sam"
            fill_in "account[surname]", :with => "Max"
            fill_in "account[email]", :with => "info@sample.com"
            fill_in "account[password]", :with => "sample"
            fill_in "account[role]", :with => "admin"
            fill_in "account[password_confirmation]", :with => "sample"
            click_button "Save"
            page.should have_selector ".notice", :content => "Account was successfully created."
            sleep 0.5
            click_link 'padrino-modal-close'
            # Check Profile works
            click_link 'user-menu'
            click_link "user-profile"
            page.should have_selector "#account_name", :value => "Foo"
            page.should have_selector "#account_surname", :value => "Bar"
            click_link "Accounts"
            # Logout
            click_link 'user-menu'
            click_link "user-logout"
            page.should have_selector "img", :title => "Login Logo"
          end

        end

        it "should generate an admin page" do
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
            2.times do
              click_link "Posts"
              click_link "new"
              fill_in "post[title]", :with => "Foo"
              fill_in "post[page]", :with => "Bar"
              click_button "Save"
              page.should have_selector ".notice", :content => "Post was successfully created."
              sleep 0.5
              click_link 'padrino-modal-close'
            end
            # Edit
            click_link "Posts"
            click_link "Edit"
            fill_in "post[title]", :with => "Padrino"
            fill_in "post[page]", :with => "Is Cool"
            click_button "Save"
            page.should have_selector ".notice", :content => "Post was successfully updated."
            sleep 0.5
            click_link 'padrino-modal-close'
            click_link "Posts"
            page.should have_selector "td", :content => "Padrino"
            page.should have_selector "td", :content => "Is Cool"
            # Destroy
            click_link "Delete"
            sleep 0.5
            click_button "delete" # confirm delete!
            page.should have_selector ".notice", :content => "Post was successfully destroyed."
            sleep 0.5
            click_link 'padrino-modal-close'
            # Multiple delete
            sleep 0.5
            click_link 'cogs'
            sleep 0.5
            click_link 'check_all' # select all post
            sleep 0.5
            click_link 'cogs'
            sleep 0.5
            click_link 'btn_multiple_delete'
            sleep 0.5
            click_button 'multiple_delete_button'
            page.should have_selector '.notice', :content => 'Posts have been successfully destroyed'
            sleep 0.5
            click_link 'padrino-modal-close'
          end
        end

        it "should detect a new file" do
          controller = "%s.controllers do; get '/' do; 'hi'; end; end" % name.capitalize
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
