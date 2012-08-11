class GamesController < ApplicationController
  def show
    @game = ::Checkers::Game.from_text(Game.all.first.state)
  end

  def play_move
    move_src, move_dest = params[:move].split('x')[0], params[:move].split('x')[1]
    @game = Game.all.first
    engine = ::Checkers::Game.from_text(@game.state)
    move = engine.options.select { |move| move.src == move_src.to_i && move.dest == move_dest.to_i }.first
    puts move
    engine.commit_move(move)
    @game.state = engine.to_s
    @game.save

    ai = ::Checkers::AI.new(::Checkers::Game.from_text(engine.to_s))
    resp = ai.choose
    move_src, move_dest = resp.to_s.split('x')
    puts "src: #{move_src}, dest: #{move_dest}"
    move = engine.options.select { |move| move.src == move_src.to_i && move.dest == move_dest.to_i }.first
    engine.commit_move(move)
    @game.state = engine.to_s
    @game.save

    redirect_to :action => "show", :id => 0
  end
end
