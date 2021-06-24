class Player
  @@player_count = 0
  @@player_hash = {}
  attr_reader :name, :hand, :id
  def initialize(name = "Player")
    @name = name
    @hand = []
    @id = @@player_count
    @@player_count += 1
    @@player_hash.store(@id, self)
  end

  def add_card_to_hand(card)
    if(card.is_a?(Array))
      set_hand(hand.concat(card))
    else
      set_hand(hand.push(card))
    end
  end

  def self.player_count
    @@player_count
  end

  def self.player_hash
    @@player_hash
  end

  def self.clear_players
    Player.set_player_count(0)
    Player.set_player_hash({})
  end

  def self.set_player_count(new_count)
    @@player_count = new_count
  end

  def self.set_player_hash(new_hash)
    @@player_hash = new_hash
  end

  def has_card?(card)
    hand.include?(card)
  end

  def self.get_player_by_id(id)
    @@player_hash[id]
  end

  def set_hand(new_hand)
    @hand = new_hand
  end

  def remove_card_from_hand(card)
    if self.hand.include?(card)
      set_hand(self.hand.reject {|hand_card| hand_card == card})
      return card
    else
      return nil
    end
  end
end
