# encoding: utf-8

require 'rubygems'
require 'require_relative'
require 'sinatra'

require 'mongoid'

class HelloSavvyWorld < Sinatra::Application
  configure :production do
    enable :logging

    set :clean_trace, true

    logger = Logger.new($stdout)

    Mongoid.configure do |config|
      name = "hellosavvyworld"
      host = "localhost"

      config.master = Mongo::Connection.new(host).db(name)
      config.logger = logger
      config.persistent_in_safe_mode = false
    end
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

