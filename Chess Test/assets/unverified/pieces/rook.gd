extends Piece
#class_name Rook

var moved: bool = false

func _init(node_ = null, type_ = 6, color_ = true, square_ = [0,0]).(node_, type_, color_, square_):
	
	direction = [[1,0], [0,1], [-1,0], [0,-1]]
