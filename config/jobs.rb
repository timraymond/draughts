require File.expand_path("../environment", __FILE__)

job "game.ai_move" do |state|
    game = Game.all.first
    engine = ::Checkers::Game.from_text(game.state)
    ai = ::Checkers::AI.new(::Checkers::Game.from_text(state['state']), :alpha_beta => true)
    resp = ai.choose
    move_src, move_dest = resp.to_s.split('x')
    move = engine.options.select { |move| move.src == move_src.to_i && move.dest == move_dest.to_i }.first
    next_player = engine.commit_move(move)
    if engine.moves.last.owner == next_player
      Stalker.enqueue("game.ai_move", :state => engine.to_s)
    end
    game.state = engine.to_s
    game.save
    PrivatePub.publish_to("/game/moves", "drawBoard(parseGame('#{game.state}'))")
end
