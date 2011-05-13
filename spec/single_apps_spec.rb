# encoding: UTF-8
require File.expand_path('../spec_helper.rb', __FILE__)

describe "single-apps" do
  attr_reader :port, :app

  def app_path(app)
    "fixtures/single-apps/#{app}.rb"
  end

  def view(name)
    "fixtures/single-apps/views/#{name}.haml"
  end

  def launch(app)
    @app, @port  = app, get_free_port
    fork { `#{Gem.ruby} #{app_path(app)} #{port}` }
    wait_localhost
  end

  def kill
    kill_match("#{app}.rb #{port}")
  end

  describe "padrino_basic.rb" do
    before(:all) { launch :padrino_basic }
    after(:all)  { kill }

    it "should get the original content" do
      visit "http://localhost:#{port}"
      body.should =~ /Im reloadable!/
    end

    it "should relaod inline content" do
      editing app_path(:padrino_basic), "Edited ...", "Edit ..." do
        visit "http://localhost:#{port}"
        body.should == "Edited ... Im reloadable!"
      end
    end
  end

  describe "padrino_advanced.rb" do
    before(:all) { launch :padrino_advanced }
    after(:all)  { kill }

    it "should get the original content" do
      visit "http://localhost:#{port}"
      body.should == "Im\n\napp\nin a layout\n"
    end

    it "should reload the view" do
      editing view(:adv1), "Your", /^Im/ do
        visit "http://localhost:#{port}"
        body.should == "Your\n\napp\nin a layout\n"
      end
    end

    it "reload the layout" do
      editing view(:layout), "custom layout", /layout/ do
        visit "http://localhost:#{port}"
        body.should == "Im\n\napp\nin a custom layout\n"
      end
    end
  end

  describe "padrino_multi.rb" do
    before(:all) { launch :padrino_multi }
    after(:all)  { kill }

    it "should get the original content" do
      visit "http://localhost:#{port}"
      body.should =~ /Given random/
      body[/(\d)/]
      random_was = $1
      visit "http://localhost:#{port}"
      body.should match(/Given random #{random_was}/)
      FileUtils.touch(app_path(:padrino_multi))
      sleep 2
      visit "http://localhost:#{port}"
      body.should_not =~ /^Given random #{random_was}$/
      visit "http://localhost:#{port}/old"
      body.should == "Old Sinatra Way"
      visit "http://localhost:#{port}/2"
      body.should == "The magick number is: 12!"
      visit "http://localhost:#{port}/2/old"
      body.should == "Old Sinatra Way"
    end

    it "should reload inline content" do
      editing app_path(:padrino_multi), "The magick number is: 14!", /The magick number is: 12!/ do
        visit "http://localhost:#{port}/2"
        body.should == "The magick number is: 14!"
      end
    end
  end

  describe "sinatra_rendering.rb" do
    before(:all) { launch :sinatra_rendering }
    after(:all)  { kill }

    it "should get the original content" do
      visit "http://localhost:#{port}"
      body.should == "Basic text"
      visit "http://localhost:#{port}/h1"
      body.should have_selector "h1", :content => "Only an h1 tag in haml"
      pending "waiting tilt haml utf8 patch" do
        visit "http://localhost:#{port}/h1"
        body.should == "∴"
      end
    end
  end

  describe "sinatra_routing.rb" do
    before(:all) { launch :sinatra_routing }
    after(:all)  { kill }

    it "should get the original content" do
      visit "http://localhost:#{port}"
      body.should == "This is foo mapped as index"
      visit "http://localhost:#{port}/bar"
      body.should == "Bar for html"
      visit "http://localhost:#{port}/bar.js"
      body.should == "Bar for js"
      visit "http://localhost:#{port}/custom-route/9"
      body.should == "This is a custom route with 9 as params[:id]"
    end
  end
end