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
    container = nil

    if not @cloudfiles.include? params["author"]
      container = @cloudfiles.create_container(params["author"])
      container.make_public
    else
      container = @cloudfiles.container(params["author"])
    end

    image = Image.new(
      :author => params["author"],
      :md5 => Digest::MD5.hexdigest(params["image"][:tempfile].read)
    )

    object = container.create_object(image.md5)
    object.write(params["image"][:tempfile], { "Content-Type" => params["image"][:type] })

    MQ = YAML.load_file(File.join("config", "mq.yml"))["development"]

    AMQP.start(MQ["uri"]) do |connection|
      channel = AMQP::Channel.new(connection)
      queue = channel.queue("savvy.images", :auto_delete => true)

      exchange = channel.direct("")
      exchange.publish(image._id, :routing_key => queue.name)

      connection.close { EventMachine.stop }
    end
    
    status 303
    headers "Location" => object.public_url
  end
  
  get "/:author/images/:image" do
    @image = Image.where(:md5 => params[:image])
    erb :image
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

