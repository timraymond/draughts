require File.expand_path("../environment", __FILE__)

job "game.ai_move" do |state|
    game = Game.all.first
    engine = ::Checkers::Game.from_text(game.state)
    ai = ::Checkers::AI.new(::Checkers::Game.from_text(state['state']))
    resp = ai.choose
    move_src, move_dest = resp.to_s.split('x')
    move = engine.options.select { |move| move.src == move_src.to_i && move.dest == move_dest.to_i }.first
    engine.commit_move(move)
    game.state = engine.to_s
    game.save
end
