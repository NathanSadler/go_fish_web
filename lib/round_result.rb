require_relative 'player'
require_relative 'deck'

class RoundResult
  attr_reader :cards, :source, :expected_rank, :recieving_player
  def initialize(cards:, recieving_player:, expected_rank: "none given",
    source: "the deck")
    cards.is_a?(Array) ? @cards = cards : @cards = [cards]
    @expected_rank = expected_rank.to_s
    @source = source
    @recieving_player = recieving_player
  end

  def matched_rank?
    cards.map(&:rank).include?(expected_rank)
  end

  def hidden_message
    if !cards.empty?
      "You took #{cards.length} #{cards[0].rank}(s) from #{source_name}"
    else
      "You took no cards"
    end
  end

  def public_message
    if expected_rank == cards[0].rank
      displayed_card_info = cards[0].rank
    else
      displayed_card_info = "card"
    end
    "#{recieving_player.name} took #{cards.length} #{displayed_card_info}(s) from #{source_name}"
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
