class Player
  # @@player_count = 0
  attr_reader :name, :hand
  def initialize(name = "Player")
    @name = name
    @hand = []
    @score = 0
    # @id =  @@player_count
    # @@player_count += 1
  end
#
  def add_card_to_hand(card)
    if(card.is_a?(Array))
      set_hand(hand.concat(card))
    else
      set_hand(hand.push(card))
    end
  end

  def set_hand(new_hand)
    @hand = new_hand
  end
#
#   def self.player_count
#     @@player_count
#   end
#
#   def self.set_player_count(new_count)
#     @@player_count = new_count
#   end
#
#
end
