require 'sinatra'
require 'sinatra/reloader'
require 'sprockets'
require 'sass'
require 'pry'
require 'pusher'
require_relative 'lib/game'
require_relative 'lib/player'
require_relative 'lib/deck'
require_relative 'lib/card'
require_relative 'lib/round_result'

class Server < Sinatra::Base
  @@game_created = false

  def self.game
    set_game_created(true)
    @@game ||= Game.new
  end

  def pusher_client
    @pusher_client ||= Pusher::Client.new(
      app_id: '1225800',
      key: 'cb19a8810ead6b423f1e',
      secret: '0a5b61ec2c1e71f00929',
      cluster: 'us2',
      encrypted: true
    )
  end

  def self.set_game_created(new_state)
    @@game_created = new_state
  end

  def self.game_created?
    @@game_created
  end

  def self.set_game(new_game)
    @@game = new_game
  end

  def self.reset_game
    @@game = nil
    set_game_created(false)
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
    session[:current_player] = Player.new(params['name']) if !params['name'].nil?
    # For whatever reason, the first player never gets past here but the
    # second player does
    redirect('/create_game') if !Server.game_created?
    #binding.pry
    current_game = self.class.game
    current_game.add_player(session[:current_player]) if !current_game.players.include?(session[:current_player])
    redirect('/wait_to_start')
  end

  get '/wait_to_start' do
    slim :wait_to_start
  end

  get '/create_game' do
    redirect('/waiting_room') if Server.game_created?
    slim :create_game
  end

  post '/create_game' do
    self.class.set_game(Game.new(params[:minimum_players].to_i, params[:maximum_players].to_i, params[:maximum_bots].to_i))
    self.class.game.add_player(session[:current_player])
    #binding.pry
    redirect('/waiting_room')
  end

  get '/waiting_room' do
    # binding.pry
    current_game = self.class.game
    redirect('/game_results') if self.class.game.over?
    redirect('/wait_to_start') if current_game.players.length < current_game.min_players
    current_game.shuffle_and_deal if !current_game.deck.cards_dealt?
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
    session[:turn_result] = self.class.game.play_turn(asked_player, asked_card.rank)
    # TODO: make the game handle this instead of the server
    self.class.game.increment_turn_counter if !session[:turn_result].matched_rank?
    pusher_client.trigger('go-fish', 'game-over', {message: "a"}) if self.class.game.over?
    pusher_client.trigger('go-fish', 'game-changed', {message: "game changed"}) if !self.class.game.over?
    redirect '/turn_results'
  end

  get '/turn_results' do
    turn_result = session[:turn_result]
    is_over = self.class.game.over?
    slim :turn_results, locals: {turn_result: turn_result, game_over: is_over}
  end

  get '/game_results' do
    slim :game_results, locals: {game: self.class.game}
  end

  get '/:slug' do
    slim params[:slug].to_sym
  end
end
