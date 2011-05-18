# encoding: UTF-8
require File.expand_path('../spec_helper.rb', __FILE__)

describe "single-apps" do
  attr_reader :app

  def app_path(app)
    File.expand_path("../../fixtures/single-apps/#{app}.rb", __FILE__)
  end

  def view(name)
    File.expand_path("../../fixtures/single-apps/views/#{name}.haml", __FILE__)
  end

  def launch(app)
    Padrino.clear!
    Padrino.configure_apps { enable :sessions }
    PADRINO_ROOT.replace(File.dirname(app_path(app)))
    require app_path(app)
    if app.to_s =~ /padrino/
      @app = Padrino.application
    else app.to_s =~ /sinatra/
      @app = app.to_s.camelize.constantize
    end
  end

  describe "padrino_basic.rb" do
    before(:all) { launch :padrino_basic }

    it "should get the original content" do
      visit "/"
      body.should =~ /Im reloadable!/
    end

    it "should relaod inline content" do
      editing app_path(:padrino_basic), "Edited ...", "Edit ..." do
        visit "/"
        body.should == "Edited ... Im reloadable!"
      end
    end
  end

  describe "padrino_advanced.rb" do
    before(:all) { launch :padrino_advanced }

    it "should get the original content" do
      visit "/"
      body.should == "Im\n\napp\nin a layout\n"
    end

    it "should reload the view" do
      editing view(:adv1), "Your", /^Im/ do
        visit "/"
        body.should == "Your\n\napp\nin a layout\n"
      end
    end

    it "reload the layout" do
      editing view(:layout), "custom layout", /layout/ do
        visit "/"
        body.should == "Im\n\napp\nin a custom layout\n"
      end
    end
  end

  describe "padrino_multi.rb" do
    before(:all) { launch :padrino_multi }

    it "should get the original content" do
      visit "/"
      body.should =~ /Given random/
      visit "/old"
      body.should == "Complex1Demo"
      visit "/2"
      body.should == "The magick number is: 12!"
      visit "/2/old"
      body.should == "Complex2Demo"
    end

    it "should reload app 1" do
      visit "/"
      body[/(\d)/]
      random_was = $1
      visit "/"
      body.should match(/Given random #{random_was}/)
      FileUtils.touch(app_path(:padrino_multi))
      sleep 2
      visit "/"
      body.should_not =~ /^Given random #{random_was}$/
      visit "/old"
      body.should == "Complex1Demo"
      visit "/2/old"
      body.should == "Complex2Demo"
    end

    it "should reload app 2" do
      editing app_path(:padrino_multi), "The magick number is: 14!", /The magick number is: 12!/ do
        visit "/2"
        debugger
        body.should == "The magick number is: 14!"
      end
      visit "/old"
      body.should == "Complex1Demo"
      visit "/2/old"
      body.should == "Complex2Demo"
    end
  end

  describe "sinatra_rendering.rb" do
    before(:all) { launch :sinatra_rendering }

    it "should get the original content" do
      visit "/"
      body.should == "Basic text"
      visit "/h1"
      body.should have_selector "h1", :content => "Only an h1 tag in haml"
      pending "waiting tilt haml utf8 patch" do
        visit "/h1"
        body.should == "∴"
      end
    end
  end

  describe "sinatra_routing.rb" do
    before(:all) { launch :sinatra_routing }

    it "should get the original content" do
      visit "/"
      body.should == "This is foo mapped as index"
      visit "/bar"
      body.should == "Bar for html"
      visit "/bar.js"
      body.should == "Bar for js"
      visit "/custom-route/9"
      body.should == "This is a custom route with 9 as params[:id]"
    end
  end
end