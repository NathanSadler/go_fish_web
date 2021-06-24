class Player
  attr_reader :name, :hand
  def initialize(name = "Player")
    @name = name
    @hand = []
    @score = 0
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      set_hand(hand.concat(card))
    else
      set_hand(hand.push(card))
    end
  end

  def has_card?(card)
    hand.include?(card)
  end

  def set_hand(new_hand)
    @hand = new_hand
  end
end
