require_relative 'card'
#
class Deck
  attr_reader :cards, :cards_dealt
  def initialize(specified_cards=Deck.default_deck)
    @cards = specified_cards
    @cards_dealt = false
  end
#
  def self.default_deck
    ranks = (2..10).to_a.concat(["A", "J", "Q", "K"])
    suits = ["S", "D", "H", "C"]
    card_list = []
    ranks.each do |rank|
      suits.each {|suit| card_list.push(Card.new(rank, suit))}
    end
    card_list
  end

  def cards_dealt?
    cards_dealt
  end

  def draw_card
    cards.shift
  end

  def cards_in_deck
    cards.length
  end


end
