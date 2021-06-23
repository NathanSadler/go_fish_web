require_relative 'deck'
class Game
  attr_reader :max_players, :min_players, :move_pointer, :deck, :turn_counter
  attr_accessor :players
#
  def initialize(max_players = 7, min_players = 2)
    @players = []
    @max_players = max_players
    @min_players = min_players
    @move_pointer = nil
    @turn_counter = 0
    @deck = Deck.new
  end
#
  def add_player(player)
    players.append(player)
  end

  def turn_player
    players[turn_counter]
  end

  def deal_cards
    players.length > 3 ? (card_deal_count = 5) : (card_deal_count = 7)
    card_deal_count.times do
      players.each {|player| player.add_card_to_hand(deck.draw_card)}
    end
    set_cards_dealt(true)
  end

  def increment_turn_counter
    set_turn_counter(turn_counter + 1)
  end

  private
    def set_turn_counter(new_value)
      @turn_counter = new_value % players.length
    end

    def set_cards_dealt(value)
      @cards_dealt = value
    end

end
