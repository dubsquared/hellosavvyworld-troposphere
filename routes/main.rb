# encoding: utf8

class HelloSavvyWorld < Sinatra::Application

  not_found do
    halt 404, "This is not the image you're looking for."
  end

end

