# Stores the GUI representation of a chess piece
extends Sprite
# Class Referenes!
var main
# Member Variables!
var active
var piece
# ----- ----- ----- ----- -----

# Initializes the GUI by passing in parameters for memember variables.
func init(main_reference, piece_reference):
	main = main_reference
	piece = piece_reference
	texture = main.util.compute_sprite_address(piece)
	global_position = translate_position(piece.piece_position)

# Game logic for handling user input in the GUI.
func _input_event(_viewport, _event, _shape_idx):
	if Input.is_action_just_pressed("ui_click"):
		if main.alliance_turn == piece.piece_alliance:
			active = true
			var moves = []
			var captures = []
			for move in main.return_piece_moves(piece):
				if ((move is main.Move.Capture or move is main.Move.En_Passant) or 
						(move is main.Move.Pawn_Promotion and 
						 move.move_type == main.Move.Pawn_Promotion.Move_Type.CAPTURE_MOVE)):
					captures.append(move)
				else:
					moves.append(move)
			main.activate_hint(moves)
			main.activate_attention(captures)
	if Input.is_action_just_released("ui_click"):
		if active:
			prompt_move()
			main.activate_hint([])
			main.activate_attention([])
			main.activate_focus([])
			active = false

# Contains the code for dragging pieces within the GUI.
func _physics_process(_delta):
	if active:
		self.global_position = get_global_mouse_position()
		main.activate_focus([translate_coord(global_position)])
# ----- ----- ----- ----- -----

# Updates the GUI to correspond with the internal main.board_state.
func update_gui():
	global_position = translate_position(piece.piece_position)

# Attempts to make a move from user input. If the move is illegal, it resets the piece to it position.
func prompt_move():
	var move_destination = translate_coord(global_position)
	for move in main.return_piece_moves(piece):
		if move.move_destination == move_destination:
			move.execute_move()
			main.activate_highlight([move])
			break
	update_gui()
# ----- ----- ----- ----- -----

# Translates a position within the main.board_state into coordinates on the screen.
func translate_position(position) -> Vector2:
	return Vector2((64 * position[0]) - 32, 544 - (64 * position[1]))

# Translates a coordinate on the screen into a position within the main.board_state.
func translate_coord(coord) -> Vector2:
	return Vector2(clamp(int(round((coord[0] + 32) / 64)), 1, 8), 
				   clamp(int(round((544 - coord[1]) / 64)), 1, 8))
# ----- ----- ----- ----- -----
