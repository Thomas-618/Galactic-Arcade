extends Piece
#class_name King

func _init(node_ = null, type_ = 6, color_ = true, square_ = [0,0]).(node_, type_, color_, square_):
	
	direction = [[1,1], [-1,1], [-1,-1], [1,-1], [1,0], [0,1], [-1,0], [0,-1]]
	
	
func compile_moves():
	var square_
	
	for orientation in direction:
		square_ = [square[0] + orientation[0], square[1] + orientation[1]]
		if Board.state[square_[0] + 2][square_[1] + 2] != 0:
			compile_captures(square_)
			continue
		moves.append(square_)
	Board.hint(moves)
