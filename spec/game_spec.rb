require_relative '../lib/game'
require_relative '../lib/player'
require_relative '../lib/round_result'
require 'pry'

describe "Game" do
  let(:game) {Game.new}

  context '.initialize' do
    it "creates a new Game with no players" do
      expect(Game.new.players).to(eq([]))
    end
  end

  after(:each) do
    Player.clear_players
  end

  context '#add_player' do
    it "adds a Player to the game" do
      game = Game.new
      player = Player.new
      game.add_player(player)
      expect(game.players).to(eq([player]))
    end
  end

  context '#over?' do
    before(:each) do
      2.times {game.add_player(Player.new)}
    end
    let(:player1) {game.players[0]}
    let(:player2) {game.players[1]}

    it("is true if no players have any cards and the deck is empty") do
      [player1, player2].each {|player| player.set_hand([])}
      game.deck.send(:set_cards, [])
      expect(game.over?).to(be(true))
    end

    it("is false if any players have more than one card") do
      game.deal_cards
      player1.set_hand([])
      game.deck.send(:set_cards, [])
      expect(game.over?).to(be(false))
    end

    it("is false if the deck has any cards in it") do
      [player1, player2].each {|player| player.set_hand([])}
      expect(game.over?).to(be(false))
    end
  end

  context '#play_turn' do
    before(:each) do
      [1, 2].each {|time| game.add_player(Player.new("Player #{time}"))}
      game.players[0].set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      game.players[1].set_hand([Card.new("3", "S")])
      game.deck.send(:set_cards, [Card.new("4", "C")])
    end
    let(:player1) {game.players[0]}
    let(:player2) {game.players[1]}

    it("gives card(s) to a player who correctly asks another player who asks "+
    " a specific rank") do
      game.play_turn(player2, "3")
      expect(player1.has_card?(Card.new("3", "S"))).to(eq(true))
    end

    it("removes a card from the hand of a player who gets asked for a card of "+
    "a rank they have") do
      game.play_turn(player2, "3")
      expect(player2.has_card?(Card.new("3", "S"))).to(eq(false))
    end

    it("returns the card(s) that the turn_player recieved") do
      turn_result_cards = game.play_turn(player2, "3").cards
      expect(turn_result_cards).to(eq([Card.new("3", "S")]))
    end

    it("returns the name of the player that gave the turn_player a card") do
      turn_result_source = game.play_turn(player2, "3").source_name
      expect(turn_result_source).to(eq("Player 2"))
    end

    it("returns 'the deck' as the source of the recieved card if it didn't "+
    "come from a player") do
      turn_result_source = game.play_turn(player2, "2").source
      expect(turn_result_source).to(eq("the deck"))
    end

    it("saves the results of the round") do
      turn_result = game.play_turn(player2, "2")
      expect(game.saved_rounds[0]).to(eq(turn_result))
    end

    it("gives a card from the deck to a player asking another player for a "+
    "card of a rank that other player doesn't have") do
      game.play_turn(player2, "2")
      expect(player1.has_card?(Card.new("4", "C"))).to(eq(true))
    end
  end

  context '#active_player' do
    it("returns the player whose turn it is") do
      [1, 2, 3].each {|time| game.add_player(Player.new("Player #{time}"))}
      game.increment_turn_counter
      expect(game.turn_player).to(eq(game.players[1]))
    end
  end

  context '#deal_cards' do
    it("gives 7 cards to each player if there are 3 or fewer players") do
      3.times {game.add_player(Player.new)}
      game.deal_cards
      (0..2).each {|index| expect(game.players[index].hand.length).to(eq(7))}
      # Make sure they didn't somehow get the same cards, either
      expect(game.players[0].hand == game.players[1].hand).to(eq(false))
    end

    it("gives 5 cards to each player if there are 4 or 5 players") do
      5.times {game.add_player(Player.new)}
      game.deal_cards
      (0..2).each {|index| expect(game.players[index].hand.length).to(eq(5))}
      # Make sure they didn't somehow get the same cards, either
      expect(game.players[0].hand == game.players[1].hand).to(eq(false))
    end

    it("sets the deck's cards_dealt variable to true") do
      3.times {game.add_player(Player.new)}
      game.deal_cards
      expect(game.deck.cards_dealt?).to(eq(true))
    end
  end

  context '#turn_player' do
    it "returns the player whose turn it is" do
      expect(game.turn_player).to(eq(game.players[0]))
    end
  end

  context '#save_round_result' do
    before(:each) do
      2.times {game.add_player(Player.new)}
    end
    let(:player1) {game.players[0]}
    let(:player2) {game.players[1]}
    let(:result) {RoundResult.new(cards: [Card.new("4", "C")], recieving_player: player1,
    expected_rank: "H", source: "the deck")}
    let(:result2) {RoundResult.new(cards: [Card.new("7", "D")], recieving_player: player2,
    expected_rank: "S", source: player1)}

    it("saves the results of a round") do
      game.save_round_result(result)
      game.save_round_result(result2)
      expect(game.saved_rounds).to(eq([result2, result]))
    end

    it("returns the round result it saved") do
      saved_result = game.save_round_result(result)
      expect(saved_result).to(eq(result))
    end

  end

  context '#increment_turn_counter' do
    before(:each) do
      2.times {game.add_player(Player.new("Test Player"))}
    end

    it "increases the turn counter by 1" do
      game.increment_turn_counter
      expect(game.turn_player).to(eq(game.players[1]))
    end

    it "goes back to zero if it reaches the last player" do
      2.times {game.increment_turn_counter}
      expect(game.turn_player).to(eq(game.players[0]))
    end
  end

  context '#play_turn' do
    [:player1, :player2].each_with_index {|player, index| let(player){Player.new("Player #{index+1}")}}
    before(:each) do
      player1.set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      player2.set_hand([Card.new("3", "S"), Card.new("K", "C"), Card.new("3", "H")])
      game.deck.send(:set_cards, [Card.new("4", "C")])
      game.add_player(player1)
      game.add_player(player2)
    end

    it("has the player lay down their cards at the end of their turn") do
      player1.add_card_to_hand(Card.new("3", "C"))
      game.deck.send(:set_cards, [Card.new("4", "C")])
      game.play_turn(player2, "3")
      expect(player1.hand).to(eq([Card.new("2", "D"), Card.new("K", "S")]))
    end

    it("takes card from a player if they have a card of a rank they are asked for") do
      game.play_turn(player2, "3")
      expect(player2.has_card?(Card.new("3", "S"))).to(eq(false))
    end

    it("gives card(s) to a player if they ask another player for cards of a "+
  " rank and they have them") do
      game.play_turn(player2, "3")
      expect(player1.has_card?(Card.new("3", "S"))).to(eq(true))
    end

    it("doesn't duplicate cards from the deck when a player draws a card") do
      game.play_turn(player2, "2")
      player1.hand.sort_by!(&:rank)
      expected_cards = [Card.new("2", "D"), Card.new("3", "D"),
        Card.new("4", "C"), Card.new("K", "S")]
      expect(player1.hand).to(eq(expected_cards))
    end

    it("doesn't duplicate cards that a player recieves from another player") do
      game.play_turn(player2, "3")
      rank_three_cards = player1.hand.select {|card| card.rank == "3"}
      expect(rank_three_cards.length).to(eq(3))
    end

    it("doesn't alter the suits of cards recieved from another player") do
      game.play_turn(player2, "3")
      rank_three_cards = player1.hand.select {|card| card.rank == "3"}
      rank_three_suits = rank_three_cards.map(&:suit)
      expect(rank_three_suits.sort).to(eq(["D", "H", "S"]))
    end

    it("makes a player draw a card if they ask another player for a card and "+
    " the other player doesn't have a card of that rank") do
      game.deck.send(:set_cards, [Card.new("4", "C")])
      game.play_turn(player2, "2")
      expect(player1.has_card?(Card.new("4", "C"))).to(eq(true))
    end

    it("doesn't make the player draw a card if they get a card from a player") do
      game.deck.send(:set_cards, [Card.new("4", "C")])
      game.play_turn(player2, "3")
      expect(player1.has_card?(Card.new("3", "S"))).to(eq(true))
      expect(player1.has_card?(Card.new("3", "D"))).to(eq(true))
      expect(player1.has_card?(Card.new("4", "C"))).to(eq(false))
    end

    it("returns a RoundResult object") do
      round_result = game.play_turn(player2, "3")
      expect(round_result).to(be_a(RoundResult))
    end
  end
end
