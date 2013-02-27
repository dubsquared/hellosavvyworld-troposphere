# encoding: utf-8

class HelloSavvyWorld < Sinatra::Application

  get "/images/rss.xml" do
    @images = Image.all
    builder :rss
  end

  get "/images/" do
    @images = Image.all
    erb :images
  end

  get "/images/:image" do
    # TODO Redirect to CDN URI
  end

end

