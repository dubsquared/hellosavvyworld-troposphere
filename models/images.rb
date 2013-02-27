# encoding: utf-8

require 'mongoid'

class Image
  include Mongoid::Document

  field :md5, :type => String
  field :author, :type => String
  field :orig_url, :type => String
  field :thumb_url, :type => String
  field :small_url, :type => String
  field :medium_url, :type => String
  field :large_url, :type => String
  field :created_at, :type => Date
end

