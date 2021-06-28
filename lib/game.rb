require_relative 'deck'
require_relative 'round_result'
class Game
  attr_reader :max_players, :min_players, :move_pointer, :deck, :turn_counter
  attr_accessor :players

  def initialize(max_players = 7, min_players = 2)
    @players = []
    @max_players = max_players
    @min_players = min_players
    @move_pointer = nil
    @turn_counter = 0
    @deck = Deck.new
  end

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
    deck.set_cards_dealt(true)
  end

  def play_turn(asked_player, card_rank)
    if asked_player.has_card_with_rank?(card_rank)
      recieved_cards, card_source = [turn_player.add_card_to_hand(asked_player.remove_cards_with_rank(card_rank)), asked_player]
      #turn_player.add_card_to_hand(recieved_cards)
    else
      recieved_cards, card_source = [turn_player.draw_card(deck), "the deck"]
    end
    RoundResult.new(cards: recieved_cards, source: card_source, recieving_player: turn_player, expected_rank: card_rank)
  end

  def increment_turn_counter
    set_turn_counter(turn_counter + 1)
  end

  private
    def set_turn_counter(new_value)
      @turn_counter = new_value % players.length
    end

end
