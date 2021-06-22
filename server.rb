require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'sass'
require 'pry'
require_relative 'lib/game'
require_relative 'lib/player'

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

  post '/waiting_room' do
    player = Player.new(params['name'])
    session[:current_player] = player
    self.class.game.add_player(player)
    redirect('/waiting_room')
  end

  get '/waiting_room' do
    redirect '/' if self.class.game.empty?
    slim :waiting_room, locals: { game: self.class.game, current_player: session[:current_player] }
  end

  get '/:slug' do
    slim params[:slug].to_sym
  end
end
