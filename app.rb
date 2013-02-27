# encoding: utf-8

require 'rubygems'
require 'require_relative'
require 'sinatra'

require 'mongoid'
require 'cloudfiles'

class HelloSavvyWorld < Sinatra::Application
  configure :development do
    enable :logging

    set :clean_trace, true

    CF = YAML.load_file(File.join("config", "cloudfiles.yml"))["development"]
    @cloudfiles = CloudFiles::Connection.new(:username => CF["username"], :api_key => CF["password"])

    Mongoid.load!(File.join("config", "mongoid.yml"))
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

