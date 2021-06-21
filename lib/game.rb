class Game
  attr_reader :players

  def initialize
    @players = []
  end

  def add_player(player)
    players.append(player)
  end

  def empty?
    players.empty?
  end

end
