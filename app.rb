# encoding: utf-8

require 'rubygems'
require 'require_relative'
require 'sinatra'

require 'mongoid'
require 'cloudfiles'

class HelloSavvyWorld < Sinatra::Application
  configure :production do
    enable :logging

    set :clean_trace, true

    @cloudfiles = CloudFiles::Connection.new(
      :username => "",
      :api_key => "",
      :snet => true)

    Mongoid.load!(File.expand_path(File.join("..", "config", "mongoid.yml"), File.dirname(__FILE__)))
  end

  configure :development do
  end

  helpers do
    include Rack::Utils
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

