class Player
  attr_reader :name, :hand, :score
  def initialize(name = "Player")
    @name = name
    @hand = []
    @score = 0
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      hand.concat(card)
    else
      hand.push(card)
    end
  end
end
