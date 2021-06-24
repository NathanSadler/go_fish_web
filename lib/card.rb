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
end
