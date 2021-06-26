require_relative '../lib/round_result'
require_relative '../lib/card'
require_relative '../lib/player'
require_relative '../lib/deck'

describe RoundResult do
  let(:test_cards) {[Card.new("7", "H")]}
  let(:test_player) {Player.new("Test Player")}

  context('initialize') do
    it("defaults to using 'the deck' as the source") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player, expected_rank:"4")
      expect(test_result.source).to(eq('the deck'))
    end

    it("defaults to using 'none given' as the expected_rank") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player)
      expect(test_result.expected_rank).to(eq('none given'))
    end

    it("automatically converts expected_rank into a string") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player, expected_rank:4)
      expect(test_result.expected_rank).to(eq("4"))
      expect(test_result.expected_rank).to(be_a(String))
    end
  end

  context('#source_name') do
    it("returns the name of a player if it is the source") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player, source: Player.new("Test 2"))
      expect(test_result.source_name).to(eq("Test 2"))
    end

    it("returns 'the deck' if the source is a deck") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player, source: Deck.new)
      expect(test_result.source_name).to(eq("the deck"))
    end

    it("just returns the source if it is a string") do
      test_result = RoundResult.new(cards: test_cards,
        recieving_player: test_player, source: "test string")
      expect(test_result.source_name).to(eq("test string"))
    end
  end
end