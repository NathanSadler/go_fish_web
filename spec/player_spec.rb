require_relative '../lib/player'
require_relative '../lib/card'

describe 'Player' do
  let!(:player) {Player.new}

  after(:each) do
    Player.clear_players
  end

  context 'initialize' do
    it("increments the player count by one") do
      expect(Player.player_count).to(eq(1))
    end
    it("adds a player to a hash of players") do
      expect(Player.player_hash.empty?).to(eq(false))
    end
    it("uses the player_count as its ID") do
      test_player = Player.new
      expect(test_player.id).to(eq(1))
    end
    it('creates a player with a specified name') do
      player = Player.new('John Doe')
      expect(player.name).to(eq('John Doe'))
    end
    it("defaults to the player name 'Player' if no name is specified") do
      expect(player.name).to(eq('Player'))
    end
  end

  context('#get_player_by_id') do
    it("returns the player with the given ID") do
      player1 = Player.new("Player 1")
      player2 = Player.new("Player 2")
      expect(Player.get_player_by_id(2)).to(eq(player2))
    end
  end

  context('#clear_players') do
    it("resets the player count to 0") do
      2.times {test_player = Player.new}
      Player.clear_players
      expect(Player.player_count).to(eq(0))
    end
    it("clears the player_hash") do
      2.times {test_player = Player.new}
      Player.clear_players
      expect(Player.player_hash.empty?).to(eq(true))
    end
  end

  context('.has_card?') do
    let(:card_list) {[Card.new("4", "H"), Card.new("7", "D")]}
    before(:each) do
      player.set_hand(card_list)
    end
    it("is true if the player has the specified card") do
      expect(player.has_card?(Card.new("4", "H"))).to(eq(true))
    end
    it("is false if the player doesn't have the specified card") do
      expect(player.has_card?(Card.new("Q", "D"))).to(eq(false))
    end
  end

  context('.set_hand') do
    let(:card_list) {[Card.new("4", "H"), Card.new("7", "D")]}
    it("sets the hand of the player") do
      player.set_hand(card_list)
      expect(player.hand).to(eq(card_list))
    end
    it("does not just add cards to the players hand") do
      player.add_card_to_hand(Card.new("8", "S"))
      player.set_hand(card_list)
      expect(player.hand).to(eq(card_list))
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
