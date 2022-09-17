extends Sprite

var piece
var square

var active
var capture
var location

var adjacent
var special
var directions = []

var moves = []
var captures = []

func params(piece_, square_):
	piece = piece_
	square = square_
	location = square_
onready var board = get_tree().get_root().get_child(0).get_node("board")

# ----- ----- ----- ----- -----
func init():
	global_position = Vector2((64*location[0]) + 32, 480 - (64*location[1]))
	texture = load("res://assets/sprites/pieces/%s.png" % piece)
	board.connect("capture", self, "_remove")
	if abs(piece) == 1:
		var forward = [[0,1], [0, -1]]
		match piece:
			1:
				directions.append(forward[0])
			-1:
				directions.append(forward[1])
		special = true
	if abs(piece) == 2:
		var lenticular = [[1,2], [2,1], [2,-1], [1,-2], [-1,-2], [-2,-1], [-2,1], [-1,2]]
		directions.append_array(lenticular)
	
	if abs(piece) == 3 or abs(piece) == 5 or abs(piece) == 6:
		var diagonal = [[1,1], [-1,1], [-1,-1], [1,-1]]
		directions.append_array(diagonal)
	
	if abs(piece) == 4 or abs(piece) == 5 or abs(piece) == 6:
		var orthogonal = [[1,0], [0,1], [-1,0], [0,-1]]
		directions.append_array(orthogonal)

	if abs(piece) == 6 or abs(piece) == 2 or abs(piece) == 1:
		adjacent = true
	else:
		adjacent = false

func user_click(_viewport, _event, _shape_idx):
	if board.turn != piece / abs(piece):
		return
	if Input.is_action_just_pressed("ui_click"):
		active = true
		generate_moves()
	if active and Input.is_action_just_released("ui_click"):
		active = false
		make_move()

# ----- ----- ----- ----- -----
func make_move():
	if location in moves or location in captures:
		global_position = Vector2((64*location[0]) + 32, 480 - (64*location[1]))
		board.state[square[0] + 2][square[1] + 2] = 0
		board.state[location[0] + 2][location[1] + 2] = piece
		board.turn = -(piece / abs(piece))
		if location in captures:
			capture = true
			board.capture(location)
		capture = false
		board.highlight_manager([square, location])
		board.hint_manager([])
		board.attention_manager([])
		
		square = location
		moves = []
		captures = []
	else:
		global_position = Vector2((64*square[0]) + 32, 480 - (64*square[1]))
		location = square
	board.focus_manager([])

func find_location():
	var file = clamp(int(round((global_position[0] + 32) / 64)), 1, 8) - 1
	var rank = 8 - clamp(int(round((global_position[1] + 32) / 64)), 1, 8)

	if [file, rank] != location:
		board.focus_manager([[file, rank]])
	location = [file, rank]

func generate_moves():
	var square_
	var square_state
	
	for orientation in directions:
		for cycle in range(1, 16):
			if adjacent and cycle > 1:
				if abs(piece) == 1 and special:
					square_ = [square[0] + (cycle*orientation[0]), square[1] + (cycle*orientation[1])]
					square_state = board.state[square_[0] + 2][square_[1] + 2]
					if square_state == 0:
						moves.append(square_)
					special = false
				break
			square_ = [square[0] + (cycle*orientation[0]), square[1] + (cycle*orientation[1])]
			square_state = board.state[square_[0] + 2][square_[1] + 2]
			if square_state != 0:
				if square_state == 8:
					break
				match piece / abs(piece):
					1:
						if square_state < 0:
							captures.append(square_)
					-1:
						if square_state > 0:
							captures.append(square_)
				break
			moves.append(square_)
	board.hint_manager(moves)
	board.attention_manager(captures)

func double_jump():
	pass
func en_passant():
	pass
func castle():
	pass
# ----- ----- ----- ----- -----
func _physics_process(_delta):
	if active:
		global_position = get_global_mouse_position()
		find_location()

func _remove(square_):
	if not capture:
		if square_ == square:
			self.queue_free()

# ----- ----- ----- ----- -----
