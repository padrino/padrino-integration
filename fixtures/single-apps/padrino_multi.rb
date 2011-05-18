require 'padrino-core'

module LibDemo
  def self.give_me_a_random
    @rand ||= rand(2**255)
  end
end

##
# This show a Padrino MultiApp
#
class Complex1Demo < Padrino::Application
  set :reload, true
  get("/old"){ "Complex1Demo" }
  controllers do
    get("/"){ "Given random #{LibDemo.give_me_a_random}" }
  end
end

class Complex2Demo < Padrino::Application
  set :reload, true
  get("/old"){ "Complex2Demo" }
  controllers do
    get("/"){ "The magick number is: 12!" } # Change only the number!!!
  end
end

Padrino.mount("complex_1_demo").to("/")
Padrino.mount("complex_2_demo").to("/2")
