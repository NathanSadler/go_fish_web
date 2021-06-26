require_relative 'player'
require_relative 'deck'

class RoundResult
  attr_reader :cards, :source, :expected_rank
  def initialize(cards:, recieving_player:, expected_rank: "none given",
    source: "the deck")
    @cards = cards
    @expected_rank = expected_rank.to_s
    @source = source
  end

  def matched_rank?
    cards.map(&:rank).include?(expected_rank)
  end

  # Returns the name of the source
  def source_name
    if source.is_a?(Player)
      source.name
    elsif source.is_a?(Deck)
      "the deck"
    elsif source.is_a?(String)
      source
    end
  end
end
