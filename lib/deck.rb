require_relative 'card'

class Deck
  attr_reader :cards
  def initialize(specified_cards=Deck.default_deck)
    @cards = specified_cards
  end

  def self.default_deck
    ranks = (2..10).to_a.concat(["A", "J", "Q", "K"])
    suits = ["S", "D", "H", "C"]
    card_list = []
    ranks.each do |rank|
      suits.each {|suit| card_list.push(Card.new(rank, suit))}
    end
    card_list
  end

  def shuffle
    cards.shuffle!
  end

  def draw_card
    cards.shift
  end

  def empty?
    cards.empty?
  end
end
