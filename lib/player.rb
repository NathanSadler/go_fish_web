class Player
  @@player_count = 0
  @@player_hash = {}
  attr_reader :name, :hand, :id, :score
  def initialize(name = "Player")
    @name = name
    @hand = []
    @id = @@player_count
    @score = 0
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

  def has_card_with_rank?(rank)
    (hand.select {|card| card.rank == rank}).length > 0
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

  def remove_cards_with_rank(rank)
    cards_to_remove = hand.select {|card| card.rank == rank}
    set_hand(hand - cards_to_remove)
    cards_to_remove
  end

  def find_book_ranks
    occurences = {}
    hand.each do |card|
      occurences[card.rank] ? occurences[card.rank] += 1 : occurences[card.rank] = 1
    end
    occurences.keys.select {|rank| occurences[rank] == 4}
  end

  def remove_card_from_hand(card)
    if self.hand.include?(card)
      set_hand(self.hand.reject {|hand_card| hand_card == card})
      return card
    else
      return nil
    end
  end

  def lay_down_books
    book_ranks = find_book_ranks
    books = hand.select {|card| book_ranks.include?(card.rank)}
    increase_score(books.length / 4)
    books.each do |card|
      remove_card_from_hand(card)
    end
  end

  def draw_card(deck)
    taken_card = deck.draw_card
    add_card_to_hand(taken_card)
    taken_card
  end

  def increase_score(points)
    set_score(score + points)
  end

  private
  def set_score(score)
    @score = score
  end
end
