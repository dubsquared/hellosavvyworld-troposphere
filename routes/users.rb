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
    
    CF = YAML.load_file(File.join("config", "cloudfiles.yml"))["development"]
    cloudfiles = CloudFiles::Connection.new(:username => CF["username"], :api_key => CF["password"])

    if not cloudfiles.containers.include? params["author"]
      container = cloudfiles.create_container(params["author"])
      container.make_public
    else
      container = cloudfiles.container(params["author"])
    end

    image = Image.find_or_initialize_by(
      :author => params["author"],
      :md5 => Digest::MD5.hexdigest(params["image"][:tempfile].read)
    )

    params["image"][:tempfile].rewind

    object = container.create_object(image.md5)
    object.write(params["image"][:tempfile], { "Content-Type" => "image/#{File.extname(params["image"][:filename])[1..-1]}" })

    image.cdn_url = object.public_url
    image.save

    MQ = YAML.load_file(File.join("config", "mq.yml"))["development"]

    AMQP.start(:uri => MQ["uri"]) do |connection|
      channel = AMQP::Channel.new(connection)
      exchange = channel.fanout("images")
      exchange.publish(image.md5)
      connection.close { EventMachine.stop { exit } }
    end
    
    status 303
    headers "Location" => "/#{params["author"]}/images/#{image.md5}" 
  end
  
  get "/:author/images/:image" do
    @image = Image.where(:md5 => params["image"]).first
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

