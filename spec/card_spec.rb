require_relative '../lib/card'

describe "Card" do
  context('.initialize') do
    let(:card) {Card.new("4", "S")}
    it("creates a card with a specified rank") do
      expect(card.rank).to(eq("4"))
    end
    it("creates a card with a specified suit") do
      expect(card.suit).to(eq("S"))
    end
  end

  context('description') do
    it("returns a ring describing the card") do
      test_card = Card.new("Q", "S")
      expect(test_card.description).to(eq("Queen of Spades"))
    end
  end

  context('==') do
    let(:card) {Card.new("3", "H")}
    it("is true if the other card has the same rank and suit") do
      expect(card == Card.new("3", "H")).to(eq(true))
    end
    it("is false if the other card has a different rank") do
      expect(card == Card.new("4", "H")).to(eq(false))
    end
    it("is false if the cards have different suits") do
      expect(card == Card.new("3", "S")).to(eq(false))
    end
  end
end