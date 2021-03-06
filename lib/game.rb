require_relative 'deck'
require_relative 'bot'
require_relative 'round_result'
class Game
  attr_reader :max_players, :min_players, :move_pointer, :deck, :turn_counter, :saved_rounds
  attr_accessor :players

  def initialize(max_players = 7, min_players = 2, max_bots = 0)
    @players = []
    @max_players = max_players
    @min_players = min_players
    @turn_counter = 0
    @saved_rounds = []
    @deck = Deck.new
    add_bots(max_bots)
  end

  def add_player(player)
    players.append(player)
    self.players.sort_by! {|player| player.is_a?(Bot) ? 1 : 0}
  end

  def add_bots(bots_to_add)
    bots_to_add.times do
      add_player(Bot.new("Bot Player"))
    end
  end

  def save_round_result(new_round_result)
    temp_array = saved_rounds
    set_saved_rounds(temp_array.unshift(new_round_result))
    saved_rounds[0]
  end

  def turn_player
    players[turn_counter]
  end

  def shuffle_and_deal
    deck.shuffle
    deal_cards
  end

  def over?
    player_card_counts = players.map {|player| player.hand.length}
    reduced_card_count = player_card_counts.reduce(0) {|sum, card_count| sum += card_count}
    (reduced_card_count == 0) && (deck.cards_in_deck == 0)
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
    else
      recieved_cards, card_source = [turn_player.draw_card(deck), "the deck"]
    end
    turn_player.lay_down_books
    save_round_result(RoundResult.new(cards: recieved_cards, source: card_source, recieving_player: turn_player, expected_rank: card_rank))
  end

  def increment_turn_counter
    set_turn_counter(turn_counter + 1)
    # if next player is a bot, play that bot's turn
    if turn_player.is_a?(Bot)
      bot_take_turn
    end
  end

  private
    def set_turn_counter(new_value)
      @turn_counter = new_value % players.length
    end

    def bot_take_turn
      player_picked = turn_player.select_player_from_game(self)
      rank_picked = turn_player.hand.sample.rank
      turn_result = play_turn(player_picked, rank_picked)
      if turn_result.cards[0].rank == turn_result.expected_rank
        bot_take_turn
      else
        increment_turn_counter
      end
    end

    def set_saved_rounds(new_saved_rounds)
      @saved_rounds = new_saved_rounds
    end
end
