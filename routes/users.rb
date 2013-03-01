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

    container = @cloudfiles.container(image.author)
    object = container.create_object(Digest::MD5.hexdigest(params["image"][:tempfile].read) + "-orig")
    params["image"][:tempfile].rewind
    object.write(params["image"][:tempfile].read)

    image.update_attributes(
      :md5 => object.name.chomp("-orig"),
      :orig_url => object.public_url,
      :thumb_url => object.public_url.chomp("-orig") + "-thumb",
      :small_url => object.public_url.chomp("-orig") + "-small",
      :medium_url => object.public_url.chomp("-orig") + "-medium",
      :large_url => object.public_url.chomp("-orig") + "-large"
    )

    @exchange.publish(image.md5, :routing_key => @queue.name)
    
    status 202
    headers "Location" => object.public_url
  end
  
  get "/:author/images/:image" do
    # TODO Redirect to CDN URI
  end

  delete "/:author/images/:image" do
    container = @cloudfiles.container(params[:author])

    [ "orig", "thumb", "small", "medium", "large" ].each do |key|
      begin
        object = container.delete_object(params[:image] + "-" + key)
      rescue CloudFiles::Exception::NoSuchObject
        next
      end
    end
    
    image = Image.where(:md5 => params[:image])
    
    redirect "/#{params["author"]}/images/" if image.delete
    
    halt 500, "Failed to delete image, #{:image}" # TODO Fix the error code.
  end

end

