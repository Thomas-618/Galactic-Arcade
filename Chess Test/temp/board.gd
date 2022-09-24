extends GridContainer

var turn = 1
var state = [
	[8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
	[8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8],
	[8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
	[8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8],
	]

match alliance_turn:
				Piece.Alliance.WHITE:
					var move = rng.randi_range(0, white_legal_moves.size() - 1)
					white_legal_moves[move].execute_move(self)
					debug_print()
				Piece.Alliance.BLACK:
					var move = rng.randi_range(0, black_legal_moves.size() - 1)
					black_legal_moves[move].execute_move(self)
					debug_print()

# ----- ----- ---
-- ----- -----

func _ready():
	create_piece(1, true, [6,2])
	create_piece(-2, false, [0,3])
	
	create_piece(-3, false, [1,4])
	create_piece(-4, false, [2,5])
	
	create_piece(-5, false, [3,6])
	create_piece(-6, false, [5,7])

onready var piece = preload("res://assets/scenes/piece.tscn")
func create_piece(type, color, square):
	var instance =  piece.instance()
	instance.initialize(type, color, square)
	get_tree().get_root().get_node("app/pieces").add_child(instance)

# ----- ----- ----- ----- -----

signal capture
func capture(square):
	emit_signal("capture", square)

var highlight = []
func highlight(squares):
	for square in highlight:
		get_tree().get_root().get_node("app/board/%s/%s" % [square[0], square[1]]).set_pressed(false)
	for square in squares:
		get_tree().get_root().get_node("app/board/%s/%s" % [square[0], square[1]]).set_pressed(true)
	highlight = [] + squares

var warning = [] 
func warning(squares):
	for square in warning:
		get_tree().get_root().get_node("app/board/%s/%s" % [square[0], square[1]]).set_disabled(false)
	for square in squares:
		get_tree().get_root().get_node("app/board/%s/%s" % [square[0], square[1]]).set_disabled(true)
	warning = [] + squares

var focus = []
func focus(squares):
	for square in focus:
		get_tree().get_root().get_node("app/board/%s/%s/texture/focus_indicator" % [square[0], square[1]]).visible = false
	for square in squares:
		get_tree().get_root().get_node("app/board/%s/%s/texture/focus_indicator" % [square[0], square[1]]).visible = true
	focus = [] + squares

var hint = []
func hint(squares):
	for square in hint:
		get_tree().get_root().get_node("app/board/%s/%s/texture/hint_indicator" % [square[0], square[1]]).visible = false
	for square in squares:
		get_tree().get_root().get_node("app/board/%s/%s/texture/hint_indicator" % [square[0], square[1]]).visible = true
	hint = [] + squares

var attention = []
func attention(squares: Array):
	for square in attention:
		get_tree().get_root().get_node("app/board/%s/%s/texture/attention_indicator" % [square[0], square[1]]).visible = false
	for square in squares:
		get_tree().get_root().get_node("app/board/%s/%s/texture/attention_indicator" % [square[0], square[1]]).visible = true
	attention = [] + squares

# ----- ----- ----- ----- -----
