# encoding: utf-8

require 'mongoid'

class Image
  include Mongoid::Document

  field :md5, :type => String
  field :author, :type => String
  
  field :cdn_url, :type => String

  private :cdn_url

  def url(type = "orig")
    case type
    when "orig"
      cdn_url
    when [ "thumb", "small", "medium", "large" ]
      cdn_url + "-" + type
    else
      raise ArgumentError.new("Unknown URL type, #{type}")
    end
  end

  field :created_at, :type => DateTime
end

