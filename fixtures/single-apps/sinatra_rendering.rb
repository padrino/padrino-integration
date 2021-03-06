require 'sinatra/base'
require 'padrino-core/application/rendering'
require 'haml'

##
# Small example that show you some padrino rendering.
# Point your browser to:
#
#   http://localhost:3000
#   http://localhost:3000/h1
#
class SinatraRendering < Sinatra::Application
  register Padrino::Rendering
  set :views, File.expand_path("../views", __FILE__)
  disable :logging

  get "/utf-8" do
    render :utf8
  end

  get "/" do
    "Basic text"
  end

  get "/h1" do
    render "h1"
  end
end # MyApp