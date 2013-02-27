# encoding: utf-8

class HelloSavvyWorld < Sinatra::Application
  
  get "/:author/images/" do
    @images = Image.where(:author => params["author"])
    erb :images
  end

  post "/:author/images/" do
    # Create new Mongo document for image
    # Place image in Queue
  end
  
  get "/:author/images/:image" do
    # TODO Redirect to CDN URI
    erb :image
  end

  delete "/:author/images/:image" do
    # Delete from CF
    
    image = Image.where(:md5 => params[:image])
    
    redirect "/#{params["author"]}/images/" if image.delete
    
    halt 500, "Failed to delete image, #{:image}" # TODO Fix the error code.
  end

end

