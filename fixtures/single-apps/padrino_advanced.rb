require 'padrino-core'
require 'haml'

##
# This show a Padrino Advanced App
#
class PadrinoApp1 < Padrino::Application
  register Padrino::Rendering

  layout :layout

  get :index, :map => '/' do
    render "adv1"
  end
end

Padrino.mount(PadrinoApp1).to("/")