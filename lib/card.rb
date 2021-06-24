class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def description
    letter_ranks = {"A" => "Ace", "J" => "Jack", "Q" => "Queen", "K" => "King"}
    suits = {"C" => "Clubs", "D" => "Diamonds", "H" => "Hearts", "S" => "Spades"}
    rank_description = letter_ranks.fetch(rank, rank)
    "#{rank_description} of #{suits[suit]}"
  end

  def ==(other_card)
    (self.rank == other_card.rank) && (self.suit == other_card.suit)
  end

  def self.from_str(str)
    str_rank = /[AKQJ0-9]{1,2}/.match(str)[0]
    str_suit = /-.\z/.match(str)[0][1]
    Card.new(str_rank, str_suit)
  end
end
