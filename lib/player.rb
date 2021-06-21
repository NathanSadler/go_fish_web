class Player
  attr_reader :name, :hand, :score
  def initialize(name = "Player")
    @name = name
    @hand = []
    @score = 0
  end
end
