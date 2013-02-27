# encoding: utf-8

require 'rubygems'
require 'builder'

class HelloSavvyWorld < Sinatra::Application
  
  get "/:author/images/rss.xml" do
    @images = Image.where(:author => params["author"])
    builder :rss
  end

  get "/:author/images/" do
    @images = Image.where(:author => params["author"])
    erb :images
  end

  post "/:author/images/" do
    image = Image.new(:author => params["author"], :created_at => Time.now)

    # Place image in Queue
  end
  
  get "/:author/images/:image" do
    # TODO Redirect to CDN URI
  end

  delete "/:author/images/:image" do
    # Delete from CF
    
    image = Image.where(:md5 => params[:image])
    
    redirect "/#{params["author"]}/images/" if image.delete
    
    halt 500, "Failed to delete image, #{:image}" # TODO Fix the error code.
  end

end

