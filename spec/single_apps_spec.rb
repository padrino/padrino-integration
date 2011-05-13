require File.expand_path('../spec_helper.rb', __FILE__)

describe "single-apps" do
  before { kill_match("single-apps") }
  after  { kill_match("single-apps") }

  def app_path(app)
    "fixtures/single-apps/#{app}.rb"
  end

  def view(name)
    "fixtures/single-apps/views/#{name}.haml"
  end

  def launch(app)
    fork { `#{Gem.ruby} #{app_path(app)} #{get_free_port}` }
    wait_localhost
  end

  describe "padrino_basic.rb" do
    before { launch :padrino_basic }

    it "should get the original content" do
      visit "http://localhost:3000"
      body.should =~ /Im reloadable!/
    end

    it "should relaod inline content" do
      editing app_path(:padrino_basic), "Edited ...", "Edit ..." do
        visit "http://localhost:3000"
        body.should == "Edited ... Im reloadable!"
      end
    end
  end

  describe "padrino_advanced.rb" do
    before { launch :padrino_advanced }

    it "should get the original content" do
      launch :padrino_advanced
      visit "http://localhost:3000"
      body.should == "Im\n\napp\nin a layout\n"
    end

    it "should reload the view" do
      editing view(:adv1), "Your", /^Im/ do
        visit "http://localhost:3000"
        body.should == "Your\n\napp\nin a layout\n"
      end
    end

    it "reload the layout" do
      editing view(:layout), "custom layout", /layout/ do
        visit "http://localhost:3000"
        body.should == "Im\n\napp\nin a custom layout\n"
      end
    end
  end

  describe "padrino_multi.rb" do
    before { launch :padrino_multi }

    it "should get the original content" do
      visit "http://localhost:3000"
      body.should =~ /Given random/
      body[/(\d)/]
      random_was = $1
      visit "http://localhost:3000"
      body.should match(/Given random #{random_was}/)
      FileUtils.touch(app_path(:padrino_multi))
      sleep 2
      visit "http://localhost:3000"
      body.should_not =~ /^Given random #{random_was}$/
      visit "http://localhost:3000/old"
      body.should == "Old Sinatra Way"
      visit "http://localhost:3000/2"
      body.should == "The magick number is: 12!"
      visit "http://localhost:3000/2/old"
      body.should == "Old Sinatra Way"
    end

    it "should reload inline content" do
      editing app_path(:padrino_multi), "The magick number is: 14!", /The magick number is: 12!/ do
        visit "http://localhost:3000/2"
        body.should == "The magick number is: 14!"
      end
    end
  end

  describe "sinatra_rendering.rb" do
    before { launch :sinatra_rendering }

    it "should get the original content" do
      visit "http://localhost:3000"
      body.should == "Basic text"
      visit "http://localhost:3000/h1"
      body.should have_selector "h1", :content => "Only an h1 tag in haml"
      pending "when the tilt patch will be relased" do
        visit "http://localhost:3000/h1"
        body.should == "∴"
      end
    end
  end

  describe "sinatra_routing.rb" do
    before { launch :sinatra_routing }

    it "should get the original content" do
      visit "http://localhost:3000"
      body.should == "This is foo mapped as index"
      visit "http://localhost:3000/bar"
      body.should == "Bar for html"
      visit "http://localhost:3000/bar.js"
      body.should == "Bar for js"
      visit "http://localhost:3000/custom-route/9"
      body.should == "This is a custom route with 9 as params[:id]"
    end
  end
end