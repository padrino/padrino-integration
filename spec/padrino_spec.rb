require File.expand_path('../spec_helper.rb', __FILE__)

describe "padrino" do

  def in_clean_env(&block)
    pid = fork do
      PADRINO_ROOT.replace(apptmp)
      require File.join(@apptmp, '/config/boot.rb')
      @app = Padrino.application
      # Now we can call our block
      block.call
    end
    Process.waitpid(pid)
  end

  %w(slim erb haml).each do |engine|
    %w(activerecord mini_record couchrest mongomapper sequel datamapper mongoid).each do |orm|
      # next if orm == "couchrest" && ENV['TRAVIS']
      next if orm == "couchrest" && engine == "erb"

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
            conn = Mongo::Connection.new
            conn.drop_database("#{name}_development")
            CouchRest.database!("#{name}_development").delete! unless ENV['TRAVIS']
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
          if orm !~ /mongo|couch|mini/
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
            # Logout
            click_button "Logout"
            body.should have_selector "h2", :content => "Login Box"
          end
        end

        it "should generate an admin page" do
          out = padrino_gen(:model, :post, "title:string", "body:string", "--root=#{apptmp}")
          out.should =~ /orms\/#{orm}/i
          if orm !~ /mongo|couch|mini/
            out = padrino(:rake, migrate(orm), "--chdir=#{apptmp}")
            out.should =~ /=> Executing Rake/i
          end
          out = padrino_gen(:admin_page, :post, "--root=#{apptmp}")
          out.should =~ /admin\/views\/posts/i
          # Launch project, with few hacks...
          in_clean_env do
            visit "/admin"
            fill_in :email,    :with => "info@sample.com"
            fill_in :password, :with => "sample"
            click_button "Sign In"
            # New
            2.times do
              click_link "Posts"
              click_link "New"
              fill_in "post[title]", :with => "Foo"
              fill_in "post[body]", :with => "Bar"
              click_button "Save"
              body.should have_selector ".notice", :content => "Post was successfully created."
            end
            # Edit
            click_link "Posts"
            click_button "Edit"
            fill_in "post[title]", :with => "Padrino"
            fill_in "post[body]", :with => "Is Cool"
            click_button "Save"
            body.should have_selector ".notice", :content => "Post was successfully updated."
            click_link "Posts"
            body.should have_selector "td", :content => "Padrino"
            body.should have_selector "td", :content => "Is Cool"
            # Destroy
            click_button "Delete"
            body.should have_selector ".notice", :content => "Post was successfully destroyed."
          end
        end

        # it "should detect a new file" do
        #   controller = "%s.controllers do; get '/' do; 'hi'; end; end" % name.capitalize
        #   in_clean_env do
        #     visit "/"
        #     response.ok?.should == false
        #     File.open(File.join(apptmp, 'app', 'controllers', 'base.rb'), 'w') { |f| f.write controller }
        #     Padrino.reload!
        #     visit "/"
        #     response.body.should == 'hi'
        #   end
        # end

        # it "should reload a file" do
        #   controller = File.read(File.join(apptmp, 'app', 'controllers', 'base.rb'))
        #   in_clean_env do
        #     visit "/"
        #     response.body.should == 'hi'
        #     File.open(File.join(apptmp, 'app', 'controllers', 'base.rb'), 'w') { |f| f.write controller.gsub(/hi/, 'hello') }
        #     Padrino.reload!
        #     visit "/"
        #     response.body.should == 'hello'
        #   end
        # end
      end # describe
    end # orm
  end # engine
end # describe
