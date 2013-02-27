# encoding: utf-8

require 'mongoid'

class Image
  include Mongoid::Document

  field :image, :type => String
  field :author, :type => String
  field :uris, :type => Array
end

