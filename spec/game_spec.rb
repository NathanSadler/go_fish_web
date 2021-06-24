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
    xit "sets the turn_pointer to 0 if they are the first player" do
      game = Game.new
      game.add_player(Player.new)
      expect(game.move_pointer).to(eq(0))
    end
  end


  context '.move_turn_pointer' do
    before(:each) do
      [1, 2, 3].each {|time| game.add_player(Player.new("Player #{time}"))}
    end

    xit("moves to the next player in the players array") do
      game.move_turn_pointer
      expect(game.active_player).to(eq(game.players[1]))
    end
    xit("doesn't do anything if the move_pointer is nil") do
      3.times {game.move_turn_pointer}
      expect(game.active_player).to(eq(game.players[0]))
    end
  end

  context '.take_turn' do
    before(:each) do
      [1, 2].each {|time| game.add_player(Player.new("Player #{time}"))}
    end
    xit("moves the turn pointer after the turn is over") do
      [1, 0].each do |time|
        game.take_turn
        expect(game.active_player).to(eq(game.players[time]))
      end
    end
  end

  context '.empty?' do
    xit("is true if there are no players in the game") do
      expect(game.empty?).to(eq(true))
    end
    xit("is false if there are players in the game") do
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

  context '#make_guess' do
    [:player1, :player2].each_with_index {|player, index| let(player){Player.new("Player #{index+1}")}}
    before(:each) do
      player1.set_hand([Card.new("2", "D"), Card.new("3", "D"), Card.new("K", "S")])
      player2.set_hand([Card.new("3", "S"), Card.new("K", "C"), Card.new("3", "D")])
    end
    it("takes card from a player if they have a card of a rank they are asked for") do
      game.make_guess(player1, player2, "3")
      expect(player2.has_card?(Card.new("3", "S"))).to(eq(false))
    end
    it("gives card(s) to a player if they ask another player for cards of a "+
  " rank and they have them") do
      game.make_guess(player1, player2, "3")
      expect(player1.has_card?(Card.new("3", "S"))).to(eq(true))
    end
    # it("makes a player draw a card if they ask another player for a card and "+
    # " the other player doesn't have a card of that rank") do
    #
    # end
  end
end
