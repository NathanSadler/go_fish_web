class Game
#   attr_reader :max_players, :min_players, :move_pointer, :deck
#   attr_accessor :players
#
  def initialize(max_players = 7, min_players = 2)
    @players = []
    @max_players = max_players
    @min_players = min_players
    @move_pointer = nil
    @deck = Deck.new
  end
#
#   def add_player(player)
#     if players.length == 0
#       set_move_pointer(0)
#     end
#     players.append(player)
#   end
#
#   # TODO: finish this properly
#   def take_turn
#     move_turn_pointer
#   end
#
#   def deal_cards
#     players.length > 3 ? (card_deal_count = 5) : (card_deal_count = 7)
#     card_deal_count.times do
#       players.each {|player| player.add_card_to_hand(deck.draw_card)}
#     end
#     deck.cards_dealt(true)
#   end
#
#   def move_turn_pointer
#     if !move_pointer.nil?
#       set_move_pointer(move_pointer + 1)
#       if (move_pointer >= players.length)
#         set_move_pointer(0)
#       end
#     end
#   end
#
#   def empty?
#     players.empty?
#   end
#
#   def active_player
#     players[move_pointer]
#   end
#
#   def clear_players
#     set_players([])
#   end
#
#   private
#     def set_move_pointer(new_value)
#       @move_pointer = new_value
#     end
#
#     def set_players(players_list)
#       @players = players_list
#     end
#
#     attr_writer :deck
end
