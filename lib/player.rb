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

  def has_card_with_rank?(rank)
    (hand.select {|card| card.rank == rank}).length > 0
  end

  def find_book_ranks
    occurences = {}
    hand.each do |card|
      occurences[card.rank] ? occurences[card.rank] += 1 : occurences[card.rank] = 1
    end
    occurences.keys.select {|rank| occurences[rank] == 4}
  end

  def card_count
    hand.length
  end

  def remove_cards_with_rank(rank)
    cards_to_remove = hand.select {|card| card.rank == rank}
    set_hand(self.hand - cards_to_remove)
    cards_to_remove
  end

  def increase_score(points=1)
    set_score(self.score + points)
  end

  def lay_down_books
    book_ranks = find_book_ranks
    books = hand.select {|card| book_ranks.include?(card.rank)}
    increase_score(books.length / 4)
    books.each do |card|
      remove_card_from_hand(card)
    end
  end

  def remove_card_from_hand(card)
    if self.hand.include?(card)
      set_hand(self.hand.reject {|hand_card| hand_card == card})
      return card
    else
      return nil
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

  def set_score(new_score)
    @score = new_score
  end
end
