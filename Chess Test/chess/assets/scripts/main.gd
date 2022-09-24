# Comment on file purpose.
extends Node
# Class references!
onready var Move = $"../Move".Move
onready var Piece = $"../Piece".Piece
onready var Piece_Gui  = preload("res://chess/assets/scenes/piece_gui.tscn")
onready var test = $"../Test"
onready var util = $"../Util"
# Member Variables!
var alliance_turn #: Alliance
var board_state #: Dictionary
var active_pieces := []
var en_passant_pawn #: Piece
var white_legal_moves := []
var black_legal_moves := []
# ----- ----- ----- ----- -----

# Comment on function purpose.
func _ready():
	yield($"../", "ready")
	util.create_board_state()
	util.set_standard_board_state()
	#test.set_castle_test_board_state()
	util.debug_print()

# Comment on function purpose.
func next_turn():
	match alliance_turn:
		Piece.Alliance.WHITE:
			alliance_turn = Piece.Alliance.BLACK
			black_legal_moves = compile_all_legal_moves(Piece.Alliance.BLACK)
			if black_legal_moves.size() == 0:
				print("GAME OVER")
		Piece.Alliance.BLACK:
			alliance_turn = Piece.Alliance.WHITE
			white_legal_moves = compile_all_legal_moves(Piece.Alliance.WHITE)
			if white_legal_moves.size() == 0:
				print("GAME OVER")

# Comment on function purpose.
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

# Comment on function purpose.
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
# ----- ----- ----- ----- -----

# Comment on function purpose.
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

# Comment on function purpose.
func delete_piece(piece):
	piece.piece_gui.queue_free()
	alter_state(piece.piece_position, null)
	update_active_pieces()
# ----- ----- ----- ----- -----

# Comment on function purpose.
func update_active_pieces():
	active_pieces = Array()
	for position in board_state.values():
		if position is Piece:
			active_pieces.append(position)

# Comment on function purpose.
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

# Comment on function purpose.
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
					if move is Move.Capture:
						print(move.move_origin, move.move_destination)
						print(opponent_move.move_origin, move.move_destination, destination_state.piece_type, destination_state.piece_position)
		if move is Move.Pawn_Jump:
			print(move.move_destination, move.move_origin)
		if move.move_status != Move.Status.ILLEGAL:
			move.move_status = Move.Status.LEGAL
			legal_moves.append(move)
		move.unapply_move()
	return legal_moves

# Comment on function purpose.
func compile_all_pseudo_moves(alliance):
	var pseudo_moves = []
	for piece in active_pieces:
		if piece.piece_alliance == alliance:
			pseudo_moves.append_array(piece.compile_pseudo_moves())
	return pseudo_moves
# ----- ----- ----- ----- -----

var current_highlight = []
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

var current_warning = [] 
func activate_warning(positions):
	for position in current_warning:
		get_node("../../Board/%s/%s" 
				% [position[0], position[1]]).set_disabled(false)
	for position in positions:
		get_node("../../Board/%s/%s" 
				% [position[0], position[1]]).set_disabled(true)
	current_warning = [] + positions

var current_focus = []
func activate_focus(positions):
	for position in current_focus:
		get_node("../../Board/%s/%s/Texture/focus_indicator" 
				% [position[0], position[1]]).visible = false
	for position in positions:
		get_node("../../Board/%s/%s/Texture/focus_indicator" 
				% [position[0], position[1]]).visible = true
	current_focus = [] + positions

var current_hint = []
func activate_hint(positions):
	for position in current_hint:
		get_node("../../Board/%s/%s/Texture/hint_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = false
	for position in positions:
		print(position.move_destination)
		get_node("../../Board/%s/%s/Texture/hint_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = true
	current_hint = [] + positions

var current_attention = []
func activate_attention(positions):
	for position in current_attention:
		get_node("../../Board/%s/%s/Texture/attention_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = false
	for position in positions:
		get_node("../../Board/%s/%s/Texture/attention_indicator" 
				% [position.move_destination[0], position.move_destination[1]]).visible = true
	current_attention = [] + positions
