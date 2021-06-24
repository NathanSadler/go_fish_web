require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'sass'
require 'pry'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/deck'
require_relative 'lib/card'

class Server < Sinatra::Base
  def self.game
    @@game ||= Game.new
  end

  def self.reset_game
    @@game = nil
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

  post '/wait_to_start' do
    player = Player.new(params['name'])
    session[:current_player] = player
    self.class.game.add_player(player)
    redirect('/wait_to_start')
  end

  get '/wait_to_start' do
    slim :wait_to_start
  end

  get '/waiting_room' do
    current_game = self.class.game
    current_game.deal_cards if !current_game.deck.cards_dealt?
    redirect('/wait_to_start') if current_game.players.length < current_game.min_players
    slim :waiting_room, locals: { game: self.class.game, current_player: session[:current_player] }
    # slim :waiting_room, locals: {game: current_game}
  end

  get '/take_turn' do
    # redirect '/waiting_room' if session[:current_player].id != self.class.game.active_player.id
    slim :take_turn, locals: {game: self.class.game, current_player: session[:current_player]}
  end

  # TODO: finish this
  post '/make_guess' do
    asked_card = Card.from_str(params[:card])
    asked_player = Player.get_player_by_id(params[:player_id].to_i)
    # if asked_player.has_card_with_rank?(asked_card.rank)
    #   asked_player.remove_cards_with_rank(asked_card.rank).each {|card| self.class.game.turn_player.add_card_to_hand(card)}
    # end
    self.class.game.increment_turn_counter
    redirect '/turn_results'
  end

  get '/turn_results' do
    slim :turn_results
  end

  get '/:slug' do
    slim params[:slug].to_sym
  end
end
