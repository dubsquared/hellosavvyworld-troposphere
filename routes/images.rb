# encoding: utf-8

class HelloSavvyWorld < Sinatra::Application

  get "/images/" do
    @images = Image.all
    erb :images
  end

end

