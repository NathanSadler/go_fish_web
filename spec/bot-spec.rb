require_relative '../lib/bot'
require_relative '../lib/game'
require_relative '../lib/player'
require 'pry'

describe "Bot" do
  before(:each) do
    Player.clear_players
  end

  let(:test_bot) {Bot.new("Test Bot")}

  context("initialize") do
    it("creates a bot player with a specific name") do
      test_bot = Bot.new("Auto Fisherman V4")
      expect(test_bot.name).to(eq("Auto Fisherman V4"))
    end
  end

  context('#select_player_from_game') do
    let(:test_game) {Game.new}
    let(:test_player_a) {Player.new}
    let(:test_player_b) {Player.new}

    it("selects the first player in a game") do
      test_game.add_player(test_player_a)
      test_game.add_player(test_bot)
      test_player_a.set_hand([Card.new("7", "H")])
      selected_player = test_bot.select_player_from_game(test_game)
      expect(selected_player).to(eq(test_player_a))
    end

    xit("(normally) ignores players that don't have any cards") do
      test_game.add_player(test_player_a)
      test_game.add_player(test_player_b)
      test_game.add_player(test_bot)
      test_player_a.set_hand([])
      test_player_b.set_hand([Card.new("7", "H")])
      expect(test_bot.select_player_from_game(test_game)).to(eq(test_player_b))
    end

    it("doesn't select itself") do
      test_game.add_player(test_bot)
      test_game.add_player(test_player_a)
      test_game.players.each {|player| player.set_hand([Card.new("8", "S")])}
      expect(test_bot.select_player_from_game(test_game)).to(eq(test_player_a))
    end
  end
end
