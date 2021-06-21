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

  context('#has_card_with_rank?') do
    before(:each) do
      player.add_card_to_hand(Card.new("7", "K"))
    end
    it("is true if the player has a card with the specified rank") do
      expect(player.has_card_with_rank?("7")).to(eq(true))
    end
    it("is false if the player doesn't have a card with the specified rank") do
      expect(player.has_card_with_rank?("8")).to(eq(false))
    end
  end

  context('#find_book_ranks') do
    it("returns an array the ranks of each book") do
      book = ["S", "D", "H", "C"].map {|suit| Card.new( "7",  suit)}
      player.add_card_to_hand(book)
      player.add_card_to_hand(Card.new( "4",  "S"))
      expect(player.find_book_ranks).to(eq(["7"]))
    end
  end

  context('#remove_card_from_hand') do
    before(:each) do
      player.add_card_to_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("4", "D")])
    end
    it("removes specified cards from the player's hand") do
      player.remove_card_from_hand(Card.new("2", "D"))
      expect(player.hand).to(eq([Card.new("3", "D"), Card.new("4", "D")]))
    end
    it("returns the cards that it removed") do
      test_cards = Card.new("2", "D")
      expect(player.remove_card_from_hand(test_cards)).to(eq(test_cards))
    end
    it("returns nil if the player doesn't have the specified cards") do
      test_card = Card.new("2", "H")
      expect(player.remove_card_from_hand(test_card)).to(eq(nil))
    end
  end

  context("increase_score") do
    it("increases the players score by a specified amount") do
      player.increase_score(2)
      player.increase_score(1)
      expect(player.score).to(eq(3))
    end
    it("defaults to increasing the player's score by 1") do
      2.times {player.increase_score}
      expect(player.score).to(eq(2))
    end
  end

  context('#remove_cards_with_rank') do
    it('returns and removes all cards with a specified rank') do
      cards = [Card.new( "8",  "S"), Card.new( "8", "D"),
        Card.new( "4",  "H")]
      player.add_card_to_hand(cards)
      removed_cards = player.remove_cards_with_rank("8")
      expect(player.hand).to(eq([Card.new( "4",  "H")]))
      expect(removed_cards).to(eq([Card.new( "8",  "S"), Card.new( "8", "D")]))
    end
    it('returns an empty array if the player does not have cards of the '+
    'specified ranks') do
      cards = [Card.new("7", "H"), Card.new("9", "S")]
      removed_cards = player.remove_cards_with_rank("2")
      expect(removed_cards).to(eq([]))
    end
  end

  context('#lay_down_books') do
    it("removes a book from the hand and increases the player's score") do
      book = ["S", "D", "H", "C"].map {|suit| Card.new( "7",  suit)}
      player.add_card_to_hand(book)
      player.add_card_to_hand(Card.new( "4",  "S"))
      player.lay_down_books
      expect(player.hand).to(eq([Card.new( "4",  "S")]))
      expect(player.score).to(eq(1))
    end
  end

end
