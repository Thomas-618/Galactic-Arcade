extends Piece
#class_name Pawn

var moved: bool = false

func _init(node_ = null, type_ = 6, color_ = true, square_ = [0,0]).(node_, type_, color_, square_):
	if color_:
		direction = [[0,1], [1,1], [-1,1]]
	else:
		direction = [[0,-1], [1,-1], [-1,-1]]
	
	
func compile_moves():
	var square_
	
	for orientation in direction:
		if orientation[0] == 0:
			for cycle in range(1,3):
				square_ = [square[0] + (cycle * orientation[0]), square[1] + (cycle * orientation[1])]
				if Board.state[square_[0] + 2][square_[1] + 2] == 0:
					moves.append(square_)
				if moved:
					break
				moved = true
		else:
			square_ = [square[0] + orientation[0], square[1] + orientation[1]]
			if Board.state[square_[0] + 2][square_[1] + 2] != 0:
				compile_captures(square_)
	Board.hint(moves)
