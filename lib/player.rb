class Player
  @@player_count = 0
  attr_reader :name, :hand, :score, :id
  def initialize(name = "Player")
    @name = name
    @hand = []
    @score = 0
    @id =  @@player_count
    @@player_count += 1
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      hand.concat(card)
    else
      hand.push(card)
    end
  end

  def self.player_count
    @@player_count
  end

  def self.set_player_count(new_count)
    @@player_count = new_count
  end

  private
  def set_hand(new_hand)
    @hand = new_hand
  end

end
