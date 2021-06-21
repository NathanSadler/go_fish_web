require_relative '../lib/player'

describe 'Player' do
  let(:player) {Player.new}
  context 'initialize' do
    it('creates a player with a specified name') do
      player = Player.new('John Doe')
      expect(player.name).to(eq('John Doe'))
    end
    it("defaults to the player name 'Player' if no name is specified") do
      player = Player.new
      expect(player.name).to(eq('Player'))
    end
    it("starts the player without any cards") do
      expect(player.hand).to(eq([]))
    end
    it("starts the player with a score of 0") do
      expect(player.score).to(eq(0))
    end
  end

  context('#add_card_to_hand') do
    it("adds a card to the player's hand") do
      test_card = Card.new("7", "H")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([test_card]))
    end
    it("can add multiple cards to the player's hand") do
      test_cards = [Card.new("9", "C"), Card.new("K", "S")]
      player.add_card_to_hand(test_cards)
      expect(player.hand).to(eq(test_cards))
    end
    it("does not just replace the player's hand") do
      player.add_card_to_hand(Card.new("9", "D"))
      test_card = Card.new("J", "C")
      player.add_card_to_hand(test_card)
      expect(player.hand).to(eq([Card.new( "9",  "D"), test_card]))
    end
  end
end
