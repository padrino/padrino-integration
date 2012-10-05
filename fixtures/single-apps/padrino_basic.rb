require 'padrino-core'

##
# Small example of a simple Padrino Application
#
class PadrinoBasic < Padrino::Application

  get :index, :map => '/' do
    "Edited ... Im reloadable!"
  end
end

Padrino.mount("PadrinoBasic").to("/")
