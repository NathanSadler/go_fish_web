require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'sass'
require_relative 'lib/game'

class Server < Sinatra::Base
  def self.game
    @@game ||= Game.new
  end

  configure :development do
    register Sinatra::Reloader
  end
  enable :sessions

  # initialize new sprockets environment
  set :environment, Sprockets::Environment.new

  # append assetls paths
  environment.append_path "assets/stylesheets"
  environment.append_path "assets/javascripts"

  # compress assets
  environment.css_compressor = :scss

  # get assets
  get "/assets/*" do
    env["PATH_INFO"].sub!("/assets", "")
    settings.environment.call(env)
  end

  get '/' do
    slim :index
  end

  get '/:slug' do
    slim params[:slug].to_sym
  end
end
