require_relative '../lib/game'
require_relative '../lib/player'

describe "Game" do
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
  end

  context '.empty?' do
    let(:game) {Game.new}
    it("is true if there are no players in the game") do
      expect(game.empty?).to(eq(true))
    end
    it("is false if there are players in the game") do
      game.add_player(Player.new)
      expect(game.empty?).to(eq(false))
    end
  end
end
