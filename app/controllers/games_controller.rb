class GamesController < ApplicationController
  def show
    @game = ::Checkers::Game.from_text(Game.all.first.state)
  end

  def play_move
    move_src, move_dest = params[:move].split('x')[0], params[:move].split('x')[1]
    @game = Game.all.first
    engine = ::Checkers::Game.from_text(@game.state)
    move = engine.options.select { |move| move.src == move_src.to_i && move.dest == move_dest.to_i }.first
    if move
      engine.commit_move(move)
      @game.state = engine.to_s
      @game.save

      Stalker.enqueue("game.ai_move", :state => engine.to_s)

    else
      @error = true
    end
    respond_to do |format|
      format.js
    end
  end

  def reset
    game = Game.all.first
    game.state = "bbbbbbbbbbbbxxxxxxxxwwwwwwwwwwww:b"
    game.save

    @game = ::Checkers::Game.from_text(game.state)

    render :action => "show"
  end
end
