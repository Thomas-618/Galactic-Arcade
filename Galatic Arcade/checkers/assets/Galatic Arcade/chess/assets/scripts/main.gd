# Stores logic for the main functioning of the program.
# (calls the other scripts)
extends Node
# Class references!
onready var Move = $"../Move".Move
onready var Piece = $"../Piece".Piece
onready var Piece_Gui  = preload("res://chess/assets/scenes/piece_gui.tscn")
onready var test = $"../Test"
onready var util = $"../Util"
# Data Types!
enum Game_State {ONGOING, CHECKMATE, STALEMATE, DRAW, INSUFFCIENT}
# Member Variables!
var game_state #: Game_State
var alliance_turn #: Piece.Alliance
var board_state #: Dictionary
var active_pieces := []
var fifty_move_rule := 0
var en_passant_pawn #: Piece
var white_legal_moves := []
var black_legal_moves := []
var recent_move #: Move
# ----- ----- ----- ----- -----

# TODO: Implement Resign
# TODO: Implement Menu
# TODO: Implement Game_State GUI
# TODO Implement Gui bruh

# Upon the first loading of the program, this function executes, setting up the program.
func _ready():
	yield($"../", "ready") # Postpones executing code until other scripts have been loaded.
	util.create_board_state()
	util.set_standard_board_state()
	#test.set_castle_test_board_state()
	util.debug_print()

# Progresses to the next turn, calling necessary functions to check for win conditions.
func next_turn():
	alliance_turn = util.get_opponent_alliance(alliance_turn)
	match alliance_turn:
		Piece.Alliance.WHITE:
			white_legal_moves = compile_all_legal_moves(alliance_turn)
			for move in black_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(false)
			for move in white_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(true)
		Piece.Alliance.BLACK:
			black_legal_moves = compile_all_legal_moves(alliance_turn)
			for move in white_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(false)
			for move in black_legal_moves:
				move.move_piece.piece_gui.feedback_indicator(true)
	assess_state()
	print(game_state)

# Alters the board_state at a certain position and setting the value to the alteration.
func alter_state(position, alteration):
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
	if alliance_turn == Piece.Alliance.WHITE:
		legal_moves.append_array(white_legal_moves)
	elif alliance_turn == Piece.Alliance.BLACK:
		legal_moves.append_array(black_legal_moves)
	if legal_moves.size() == 0:
		game_state = Game_State.STALEMATE
		for opponent_move in compile_all_pseudo_moves(util.get_opponent_alliance(alliance_turn)):
			var destination_state = access_state(opponent_move.move_destination)
			if destination_state == null:
				continue
			if (destination_state.piece_type == Piece.Type.KING and 
					destination_state.piece_alliance == Piece.Alliance.WHITE):
				game_state = Game_State.CHECKMATE
	if game_state != Game_State.ONGOING:
		return
	game_state = Game_State.INSUFFCIENT
	var piece_count = 0
	for piece in active_pieces:
		if (piece.piece_type == Piece.Type.QUEEN or
				piece.piece_type == Piece.Type.ROOK or 
				piece.piece_type == Piece.Type.PAWN):
			game_state = Game_State.ONGOING
			break
		if (piece.piece_type == Piece.Type.BISHOP or piece.piece_type == Piece.Type.KNIGHT):
			piece_count += 1
		if piece_count > 2:
			game_state = Game_State.ONGOING
			break
	if game_state != Game_State.ONGOING:
		return
	if not recent_move is Move:
		return
	if recent_move.move_piece.piece_type is Piece.Pawn or recent_move is Move.Capture:
		fifty_move_rule = 0
	else:
		fifty_move_rule += 1
	if fifty_move_rule == 50:
		game_state = Game_State.DRAW
# ----- ----- ----- ----- -----

# Creates a piece, including the a Piece class instance and an instance of the piece_gui.
func create_piece(piece_alliance, piece_type, piece_position, piece_moved = false):
	var piece
	var piece_gui = Piece_Gui.instance()
	match piece_type:
		Piece.Type.KING:
			piece = Piece.King.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
		Piece.Type.QUEEN:
			piece = Piece.Queen.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
		Piece.Type.ROOK:
			piece = Piece.Rook.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
		Piece.Type.BISHOP:
			piece = Piece.Bishop.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
		Piece.Type.KNIGHT:
			piece = Piece.Knight.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
		Piece.Type.PAWN:
			piece = Piece.Pawn.new(self, piece_gui, piece_alliance, piece_position, piece_moved)
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
	if piece.piece_alliance == Piece.Alliance.WHITE:
		for move in white_legal_moves:
			if move.move_piece == piece:
				legal_moves.append(move)
	if piece.piece_alliance == Piece.Alliance.BLACK:
		for move in black_legal_moves:
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

# Compiles the pseudo_legal moves of an alliance and the opposite alliance and checks for illegal moves.
func compile_all_legal_moves(alliance):
	var legal_moves = []
	var pseudo_moves = compile_all_pseudo_moves(alliance)
	for move in pseudo_moves:
		move.apply_move()
		var opponent_moves = compile_all_pseudo_moves(util.get_opponent_alliance(alliance))
		for opponent_move in opponent_moves:
			var destination_state = access_state(opponent_move.move_destination)
			if destination_state is Piece:
				if (destination_state.piece_type == Piece.Type.KING and 
						destination_state.piece_alliance == alliance):
					move.move_status = Move.Status.ILLEGAL
		if move.move_status != Move.Status.ILLEGAL:
			move.move_status = Move.Status.LEGAL
			legal_moves.append(move)
		move.unapply_move()
	return legal_moves

# Calls all the pieces of an alliance to return their pseudo legal moves.
func compile_all_pseudo_moves(alliance):
	var pseudo_moves = []
	for piece in active_pieces:
		if piece.piece_alliance == alliance:
			pseudo_moves.append_array(piece.compile_pseudo_moves())
	return pseudo_moves
# ----- ----- ----- ----- -----
