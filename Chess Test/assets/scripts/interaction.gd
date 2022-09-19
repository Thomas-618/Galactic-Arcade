extends Sprite

var piece
var active

# Comment on function purpose.
func params(piece_reference):
	piece = piece_reference

# Comment on function purpose.
func set_sprite():
	var sprite_address = []
	match piece.piece_alliance:
		0:
			sprite_address.append("white")
		1:
			sprite_address.append("black")
	match piece.piece_type:
		0:
			sprite_address.append("king")
		1:
			sprite_address.append("queen")
		2:
			sprite_address.append("rook")
		3:
			sprite_address.append("bishop")
		4:
			sprite_address.append("knight")
		5:
			sprite_address.append("pawn")
	return sprite_address

# Comment on function purpose.
func _ready():
	texture = load("res://assets/sprites/pieces/%s/%s.png" % set_sprite())
	global_position = Vector2((64 * (piece.piece_position[0] - 1)) + 32, 480 - (64 * (piece.piece_position[1] - 1)))

func update_pieece():
	global_position = Vector2((64 * (piece.piece_position[0] - 1)) + 32, 480 - (64 * (piece.piece_position[1] - 1)))
# ----- ----- ----- ----- -----

# Comment on function purpose.
func _input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("ui_click"):
		active = true
	if Input.is_action_just_released("ui_click"):
		active = false

# Comment on function purpose.
func _physics_process(_delta):
	if active:
		self.global_position = get_global_mouse_position()





