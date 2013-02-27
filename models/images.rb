# encoding: utf-8

require 'mongoid'

class Image
  include Mongoid::Document

  field :md5, :type => String
  field :author, :type => String
  field :uris, :type => Array
  field :created_at, :type => Date
end

