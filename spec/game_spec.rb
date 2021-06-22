require_relative '../lib/game'
require_relative '../lib/player'

describe "Game" do
  let(:game) {Game.new}

  context '.initialize' do
    it "creates a new Game with no players" do
      expect(Game.new.players).to(eq([]))
    end
  end

  context '.add_player' do
    it "adds a Player to the game" do
      game = Game.new
      player = Player.new
      game.add_player(player)
      expect(game.players).to(eq([player]))
    end
    it "sets the turn_pointer to 0 if they are the first player" do
      game = Game.new
      game.add_player(Player.new)
      expect(game.move_pointer).to(eq(0))
    end
  end

  context '.move_turn_pointer' do
    before(:each) do
      [1, 2, 3].each {|time| game.add_player(Player.new("Player #{time}"))}
    end

    it("moves to the next player in the players array") do
      game.move_turn_pointer
      expect(game.active_player).to(eq(game.players[1]))
    end
    it("doesn't do anything if the move_pointer is nil") do
      3.times {game.move_turn_pointer}
      expect(game.active_player).to(eq(game.players[0]))
    end
  end

  context '.take_turn' do
    before(:each) do
      [1, 2].each {|time| game.add_player(Player.new("Player #{time}"))}
    end
    it("moves the turn pointer after the turn is over") do
      [1, 0].each do |time|
        game.take_turn
        expect(game.active_player).to(eq(game.players[time]))
      end
    end
  end

  context ".clear_players" do
    it("removes all players from the game") do
      3.times {game.add_player(Player.new)}
      game.clear_players
      expect(game.players).to(eq([]))
    end
  end

  context '.empty?' do
    it("is true if there are no players in the game") do
      expect(game.empty?).to(eq(true))
    end
    it("is false if there are players in the game") do
      game.add_player(Player.new)
      expect(game.empty?).to(eq(false))
    end
  end

  context '.active_player' do
    it("returns the player whose turn it is") do
      # TODO: finish this test
      [1, 2, 3].each {|time| game.add_player(Player.new("Player #{time}"))}
    end
  end
end
