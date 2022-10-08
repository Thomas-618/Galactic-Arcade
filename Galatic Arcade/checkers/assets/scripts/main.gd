# Stores logic for the main functioning of the program.
# (calls the other scripts)
extends Node
# Class/Script References!
onready var Move = $"../Move".Move
onready var Piece = $"../Piece".Piece
onready var Piece_Gui = preload("res://checkers/assets/scenes/piece_gui.tscn")
onready var test = $"../Test"
onready var util = $"../Util"
# Data Types!
enum Game_State {ONGOING, OVER}
# Member Variables!
var game_state #: Game_State
var alliance_turn #: Piece.Alliance
var board_state #: Dictionary
var active_pieces := []
var black_legal_moves := []
var red_legal_moves := []
var recent_move #: Move
# ----- ----- ----- ----- -----

# TODO: Change Class references to Class/Scrpit
# TODO: Implement Resign
# TODO: Implement Menu
# TODO: Implement Game_State GUI
# TODO Implement Gui bruh

# Upon the first loading of the program, this function executes, setting up the program.
func _ready():
	yield($"../", "ready") # Postpones executing code until other scripts have been loaded.
	util.create_board_state()
	util.set_standard_board_state()
	# test.set_promotion_test_board_state()
	util.debug_print()

# Progresses to the next turn, calling necessary functions to check for win conditions.
func next_turn():
	if (recent_move is Move.Capture or 
				(recent_move is Move.Promotion and 
				 recent_move.move_type == Move.Promotion.Move_Type.CAPTURE_MOVE)):
		for move in compile_all_legal_moves(alliance_turn):
			if (move is Move.Capture or 
					(move is Move.Promotion and 
					 move.move_type == Move.Promotion.Move_Type.CAPTURE_MOVE)):
				alliance_turn = util.get_opponent_alliance(alliance_turn)
				break
	alliance_turn = util.get_opponent_alliance(alliance_turn)
	match alliance_turn:
		Piece.Alliance.BLACK:
			for move in black_legal_moves:
				if is_instance_valid(move.move_piece.piece_gui):
					move.move_piece.piece_gui.feedback_indicator(false)
			black_legal_moves = compile_all_legal_moves(alliance_turn)
			for move in red_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(false)
			for move in black_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(true)
		Piece.Alliance.RED:
			for move in red_legal_moves:
				if is_instance_valid(move.move_piece.piece_gui):
					move.move_piece.piece_gui.feedback_indicator(false)
			red_legal_moves = compile_all_legal_moves(alliance_turn)
			for move in black_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(false)
			for move in red_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(true)
	assess_state()

# Alters the board_state at a certain position and setting the value to the alteration.
func alter_state(position: Vector2, alteration):
	if position == null:
		return util.Error.NULL
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[0] and 
			position[0] <= util.ENDING_COORD_OF_BOARD_LENGTH):
		return util.Error.OUT_OF_RANGE
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[1] and 
			position[1] <= util.ENDING_COORD_OF_BOARD_LENGTH):
		return util.Error.OUT_OF_RANGE
	board_state[position] = alteration
	if alteration is Piece:
		alteration.piece_position = position

# Accesses the board_state and returns the value at the position.
func access_state(position):
	if position == null:
		return util.Error.NULL
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[0] and 
			position[0] <= util.ENDING_COORD_OF_BOARD_LENGTH):
		return util.Error.OUT_OF_RANGE
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[1] and 
			position[1] <= util.ENDING_COORD_OF_BOARD_LENGTH):
		return util.Error.OUT_OF_RANGE
	return board_state[position]

# Assesses the board_state checking for win conditions.
func assess_state():
	var legal_moves = []
	if alliance_turn == Piece.Alliance.BLACK:
		if black_legal_moves.size() == 0:
			game_state = Game_State.OVER
	elif alliance_turn == Piece.Alliance.RED:
		if red_legal_moves.size() == 0:
			game_state = Game_State.OVER
	if active_pieces.size() == 0:
		game_state = Game_State.OVER
# ----- ----- ----- ----- -----

# Creates a piece, including the a Piece class instance and an instance of the piece_gui.
func create_piece(piece_alliance, piece_type, piece_position):
	var piece
	var piece_gui = Piece_Gui.instance()
	match piece_type:
		Piece.Type.KING:
			piece = Piece.King.new(self, piece_gui, piece_alliance, piece_position)
		Piece.Type.PAWN:
			piece = Piece.Pawn.new(self, piece_gui, piece_alliance, piece_position)
	alter_state(piece_position, piece)
	piece_gui.init(self, piece)
	$"../../Pieces".add_child(piece_gui)
	return piece 

# Deletes the piece_gui and updates the active_pieces.
func delete_piece(piece):
	piece.piece_gui.queue_free()
	alter_state(piece.piece_position, null)
	update_active_pieces()
# ----- ----- ----- ----- -----

# Iterates through the board_state and updates the active_pieces list.
func update_active_pieces():
	active_pieces = Array()
	for position in board_state.values():
		if position is Piece:
			active_pieces.append(position)

# Iterates through the legal moves for the alliance and returns the moves for the piece.
func return_piece_moves(piece):
	var legal_moves = []
	if piece.piece_alliance == Piece.Alliance.BLACK:
		for move in black_legal_moves:
			if move.move_piece == piece:
				legal_moves.append(move)
	if piece.piece_alliance == Piece.Alliance.RED:
		for move in red_legal_moves:
			if move.move_piece == piece:
				legal_moves.append(move)
	return legal_moves
# ----- ----- ----- ----- -----

var current_highlight := []
# Board GUI: Deactivates the previously highlighted pieces and activates the highlight on the positions.
func activate_highlight(positions):
	for position in current_highlight:
		get_node("../../Board/%s/%s" 
				% [position.move_origin[0], position.move_origin[1]]).set_pressed(false)
		get_node("../../Board/%s/%s" 
				% [position.move_destination[0], position.move_destination[1]]).set_pressed(false)
	for position in positions:
		get_node("../../Board/%s/%s" 
				% [position.move_origin[0], position.move_origin[1]]).set_pressed(true)
		get_node("../../Board/%s/%s" 
				% [position.move_destination[0], position.move_destination[1]]).set_pressed(true)
	current_highlight = [] + positions

var current_warning := []
# Board GUI: Deactivates the previously warned pieces and activates the warning on the positions.
func activate_warning(positions):
	for position in current_warning:
		get_node("../../Board/%s/%s" 
				% [position[0], position[1]]).set_disabled(false)
	for position in positions:
		get_node("../../Board/%s/%s" 
				% [position[0], position[1]]).set_disabled(true)
	current_warning = [] + positions

var current_focus := []
# Board GUI: Deactivates the previously focused positions and activates the focus on the positions.
func activate_focus(positions):
	for position in current_focus:
		get_node("../../Board/%s/%s/Texture/focus_indicator" 
				% [position[0], position[1]]).visible = false
	for position in positions:
		get_node("../../Board/%s/%s/Texture/focus_indicator" 
				% [position[0], position[1]]).visible = true
	current_focus = [] + positions

var current_hint := []
# Board GUI: Deactivates the previously hinted positions and activates the hint on the positions.
func activate_hint(positions):
	for position in current_hint:
		get_node("../../Board/%s/%s/Texture/hint_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = false
	for position in positions:
		get_node("../../Board/%s/%s/Texture/hint_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = true
	current_hint = [] + positions

var current_attention := []
# Board GUI: Deactivates the previously attentioned positions and activates the attention on the positions.
func activate_attention(positions):
	for position in current_attention:
		get_node("../../Board/%s/%s/Texture/attention_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = false
	for position in positions:
		get_node("../../Board/%s/%s/Texture/attention_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = true
	current_attention = [] + positions
# ----- ----- ----- ----- -----

# Calls all the pieces of an alliance to return their legal moves.
func compile_all_legal_moves(alliance):
	var captures = []
	var moves = []
	for piece in active_pieces:
		if piece.piece_alliance == alliance:
			var piece_moves = piece.compile_moves()
			captures.append_array(piece_moves[0])
			moves.append_array(piece_moves[1])
	if captures.size() > 0:
		return captures
	return moves
# ----- ----- ----- ----- -----
