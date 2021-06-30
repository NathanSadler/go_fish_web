require_relative 'player'

class Bot < Player

  def select_player_from_game(game)
    game.players.each do |player|
      if player.id != id
        return player
      end
    end
  end

end
