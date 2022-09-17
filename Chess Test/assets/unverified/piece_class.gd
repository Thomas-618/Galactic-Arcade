extends Sprite
#class_name Piece

var node: Node
var type: int
var color: bool

var square: Array
var location: Array

var direction: Array
var moves: Array = []
var captures: Array = []

# ----- ----- ----- ----- ----- 

func _init(node_ = null, type_ = 6, color_ = true, square_ = [0,0]):
	if node_ != null:
		node = node_
		type = type_
		color = color_
		square = square_
		
		_set_up()

func _set_up():
	Board.state[square[0] + 2][square[1] + 2] = type
	node.global_position = convert_square(square)
	node.texture = load("res://assets/sprites/pieces/%s.png" % type)
	Board.connect("capture", self, "remove")

# ----- ----- ----- ----- ----- 

func compile_moves():
	var square_
	
	for orientation in direction:
		for cycle in range(1, 16):
			square_ = [square[0] + (cycle * orientation[0]), square[1] + (cycle * orientation[1])]
			if Board.state[square_[0] + 2][square_[1] + 2] != 0:
				compile_captures(square_)
				break
			moves.append(square_)
	Board.hint(moves)

func compile_captures(square_):
	var square_state = Board.state[square_[0] + 2][square_[1] + 2]
	
	if square_state == 8:
		return
	if color and square_state < 0:
		captures.append(square_)
	if (not color) and square_state > 0:
		captures.append(square_)
	Board.attention(captures)

func perform_move():
	if location in captures:
		perform_capture()
	if location in moves + captures:
		node.global_position = convert_square(location)
		Board.state[square[0] + 2][square[1] + 2] = 0
		Board.state[location[0] + 2][location[1] + 2] = type
		
		moves = []
		captures = []
		
		Board.highlight([square, location])
		Board.attention([])
		Board.hint([])
		Board.focus([])
		
		square = location
	else:
		node.global_position = convert_square(square)
		Board.focus([])

func perform_capture():
	Board.capture(location)

# ----- ----- ----- ----- ----- 
func remove(location_):
	if square == location_:
		node.queue_free()

func convert_coords(coord_) -> Array:
	return [clamp(int(round((coord_[0] + 32) / 64)), 1, 8) - 1, 8 - clamp(int(round((coord_[1] + 32) / 64)), 1, 8)]

func convert_square(square_) -> Vector2:
	return Vector2((64 * square_[0]) + 32, 480 - (64 * square_[1]))

# ----- ----- ----- ----- ----- 
