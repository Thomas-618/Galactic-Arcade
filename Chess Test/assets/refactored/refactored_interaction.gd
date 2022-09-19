# Comment on file purpose.
extends Sprite
# Class Referenes!
var main
var piece
# Member Variables!
var active
# ----- ----- ----- ----- -----

# Comment on function purpose.
func init(main_reference, piece_reference):
	main = main_reference
	piece = piece_reference
	
	texture = main.util.compute_sprite_address(piece)
	global_position = translate_position(piece.piece_position)

# Comment on function purpose.
func _input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("ui_click"):
		if main.alliance_turn == piece.piece_alliance:
				active = true
	if Input.is_action_just_released("ui_click"):
		if active:
			prompt_move()
			active = false

# Comment on function purpose.
func _physics_process(_delta):
	if active:
		self.global_position = get_global_mouse_position()

# Comment on function purpose.
func update_gui():
	global_position = translate_position(piece.piece_position)

# Comment on function purpose.
func prompt_move():
	var move_destination = translate_coord(global_position)
	for move in main.return_piece_moves(piece):
		if move.move_destination == move_destination:
			move.execute_move()
			break
	update_gui()

# Comment on function purpose.
func translate_position(position) -> Vector2:
	return Vector2((64 * position[0]) - 32, 544 - (64 * position[1]))

# Comment on function purpose.
func translate_coord(coord) -> Vector2:
	return Vector2(clamp(int(round((coord[0] + 32) / 64)), 1, 8), 
				   clamp(int(round((544 - coord[1]) / 64)), 1, 8))
# ----- ----- ----- ----- -----







