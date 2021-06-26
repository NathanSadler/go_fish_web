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
    self.class.game.add_player(player)
    session[:current_player] = player
    redirect('/wait_to_start')
  end

  get '/wait_to_start' do
    slim :wait_to_start
  end

  get '/waiting_room' do
    current_game = self.class.game
    if !current_game.deck.cards_dealt?
      current_game.deck.shuffle
      current_game.deal_cards
    end
    redirect('/wait_to_start') if current_game.players.length < current_game.min_players
    slim :waiting_room, locals: { game: self.class.game, current_player: session[:current_player] }
  end

  get '/take_turn' do
    redirect '/waiting_room' if session[:current_player].id != self.class.game.turn_player.id
    slim :take_turn, locals: {game: self.class.game, current_player: session[:current_player]}
  end

  post '/make_guess' do
    # TODO: Just pass the 3 instead of 3-D. Then you don't need to find the card frm string only to get the rank from it.
    asked_card = Card.from_str(params[:card])
    asked_player = Player.get_player_by_id(params[:player_id].to_i)
    session[:turn_result] = self.class.game.play_turn(self.class.game.turn_player, asked_player, asked_card.rank)
    session[:rank_match] = session[:turn_result][0].map(&:rank).include?(asked_card.rank)
    self.class.game.increment_turn_counter if !session[:rank_match]
    redirect '/turn_results'
  end

  get '/turn_results' do
    turn_result = session[:turn_result]
    rank_match = session[:rank_match]
    slim :turn_results, locals: {turn_result: turn_result, rank_match: rank_match}
  end

  get '/:slug' do
    slim params[:slug].to_sym
  end
end
