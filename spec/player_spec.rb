require_relative '../lib/player'

describe 'Player' do
  context 'initialize' do
    let(:test_player) {Player.new}
    it('creates a player with a specified name') do
      player = Player.new('John Doe')
      expect(player.name).to(eq('John Doe'))
    end
    it("defaults to the player name 'Player' if no name is specified") do
      player = Player.new
      expect(player.name).to(eq('Player'))
    end
    it("starts the player without any cards") do
      expect(test_player.hand).to(eq([]))
    end
    it("starts the player with a score of 0") do
      expect(test_player.score).to(eq(0))
    end
  end
end
