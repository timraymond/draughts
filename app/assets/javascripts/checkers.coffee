root = exports ? this

root.drawBoard = (board) ->
    # Assumes that the board is valid
    
    # Get the canvas context
    jQuery ->
      canvas = document.getElementById 'can'
      context = canvas.getContext '2d'

      cellWidth = canvas.width / 8
      cellHeight = canvas.height / 8

      # Draw the Checkerboard
      for rank in [0...8]        # Loop through ranks
          color = 'white' if rank % 2 == 0
          color = '#888' if rank % 2 == 1
          for file in [0...8]    # ..and through files
              context.fillStyle = color
              context.fillRect(file*cellWidth, rank*cellHeight, cellWidth, cellHeight) # draw the cell
              color = if color == 'white' then '#888' else 'white'

      # Draw the pieces
      for type, locations of board
          for location in locations
              coord = pdnToRF(location)
              console.log coord
              context.beginPath()
              context.arc((coord.file*cellWidth)+cellWidth/2, (coord.rank*cellHeight)+cellHeight/2, ((cellWidth+cellHeight)/4)*0.8, 0, Math.PI * 2, false)
              context.closePath()
              context.strokeStyle = "#ddd"
              context.stroke() 
              context.fillStyle = type
              context.fill()

      clicks = []
      $('#can').click (e) ->
        file = Math.floor((e.pageX-$("#can").offset().left) / cellWidth)
        rank = Math.floor((e.pageY-$("#can").offset().top) / cellHeight)
        pdn  = RFTopdn(rank, file)
        clicks.push pdn

        if clicks.length == 2
          $.post("/games/0/play_move", move: "#{clicks[0]}x#{clicks[1]}")

pdnToRF = (pdnLocation) ->
    currentpdn = 32
    for rank in [0...8]
        for file in [1,3,5,7]
           if currentpdn >= pdnLocation
               currRank = rank
               currFile = file
               currFile -= currRank % 2
           currentpdn -= 1
    {rank: currRank, file: currFile}

RFTopdn = (rank, file) ->
  currentpdn = 32
  for current_rank in [0...8]
    for current_file in [1,3,5,7]
      current_file -= current_rank % 2
      if current_rank == rank && current_file == file
        return currentpdn
      currentpdn -= 1
  currentpdn

root.parseGame = (ctp_game) ->
  board_text = ctp_game.split(":")[0]
  board = {white: [], black: [], yellow: []}
  current_idx = 1
  for square in board_text
    switch square
      when 'b' then board.black.push current_idx
      when 'w' then board.white.push current_idx
      when 'B' then board.yellow.push current_idx
      when 'W' then board.yellow.push current_idx
    current_idx = current_idx + 1
  board
    
jQuery ->
  canvas = document.getElementById 'can'
  board = parseGame canvas.getAttribute 'data-board'
  drawBoard(board)

  $('document')
    .bind "ajax:success", (event, data) ->
      alert "Ajax SUCCESS!!!"
