class Game
  attr_reader :players, :max_players, :min_players, :move_pointer

  def initialize(max_players = 7, min_players = 2)
    @players = []
    @max_players = max_players
    @min_players = min_players
    @move_pointer = nil
  end

  def add_player(player)
    if players.length == 0
      set_move_pointer(0)
    end
    players.append(player)
  end

  def empty?
    players.empty?
  end

  def move_turn_pointer
    if !move_pointer.nil?
      set_move_pointer(move_pointer + 1)
      if (move_pointer >= players.length)
        set_move_pointer(0)
      end
    end
  end

  def active_player
    players[move_pointer]
  end

  private
  def set_move_pointer(new_value)
    @move_pointer = new_value
  end

end
