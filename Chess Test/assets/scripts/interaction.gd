extends Sprite

var piece
var active

func params(piece_reference):
	piece = piece_reference

func _ready():
	var alliance
	var type
	match piece.piece_alliance:
		0:
			alliance = "white"
		1:
			alliance = "black"
	match piece.piece_type:
		0:
			type = "king"
		1:
			type = "queen"
		2:
			type = "rook"
		3:
			type = "bishop"
		4:
			type = "knight"
		5:
			type = "pawn"
	texture = load("res://assets/sprites/pieces/%s/%s.png" % [alliance, type])
	global_position = Vector2((64 * (piece.piece_position[0] - 1)) + 32, 480 - (64 * (piece.piece_position[1] - 1)))

func temp_func():
	global_position = Vector2((64 * (piece.piece_position[0] - 1)) + 32, 480 - (64 * (piece.piece_position[1] - 1)))

func _input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("ui_click"):
		active = true
	if Input.is_action_just_released("ui_click"):
		active = false

func _physics_process(_delta):
	if active:
		self.global_position = get_global_mouse_position()





