extends Node

onready var Move = $Move.Move
onready var Piece = $Piece.Piece
onready var Player = $Player.Player

onready var gui_piece = preload("res://assets/scenes/piece.tscn")

const STARTING_INDEX_OF_LENGTH = 1
const NUM_OF_SQUARES_IN_LENGTH = 8
const WHITE_STARTING_RANK = 1
const BLACK_STARTING_RANK = 8
const WHITE_DIRECTION = 1
const BLACK_DIRECTION = -1

var alliance_turn
var board_state = {}
var en_passant

var all_active_pieces

var white_king
var black_king

var white_legal_moves
var black_legal_moves

var rng = RandomNumberGenerator.new()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("ui_click"):
			print(" > Before ", en_passant)
			match alliance_turn:
				Piece.Alliance.WHITE:
					for move in white_legal_moves:
						print(" > During ", en_passant)
						if move.print_class() == 4:
							move.execute_move(self)
							break
					if alliance_turn == Piece.Alliance.WHITE:
						for move in white_legal_moves:
							print(" > Process ", en_passant)
							if move.print_class() == 3:
								move.execute_move(self)
								break
					if alliance_turn == Piece.Alliance.WHITE:
						print(" > Final ", en_passant)
						white_legal_moves[rng.randi_range(0, white_legal_moves.size() - 1)]
				Piece.Alliance.BLACK:
					for move in black_legal_moves:
						print(" > During ", en_passant)
						if move.print_class() == 4:
							move.execute_move(self)
							break
					if alliance_turn == Piece.Alliance.BLACK:
						for move in black_legal_moves:
							print(" > Process ", en_passant)
							if move.print_class() == 3:
								move.execute_move(self)
								break
					if alliance_turn == Piece.Alliance.BLACK:
						print(" > Final ", en_passant)
						black_legal_moves[rng.randi_range(0, black_legal_moves.size() - 1)]
			print(" > After ", en_passant)
			debug_print()

func _ready():
	rng.randomize()
	empty_board_state()
	standard_board_state()
	debug_print()
	compile_all_pieces()
	compile_all_legal_moves(alliance_turn)
	print(typeof(Vector2()), typeof(String()), typeof(null))
	

func derive_alliance(alliance, king = false, rank = false, opposite = false):
	match alliance:
		Piece.Alliance.WHITE:
			if opposite:
				if king:
					return black_king
				if rank:
					return BLACK_STARTING_RANK
				else:
					return Piece.Alliance.BLACK
			else:
				if king:
					return white_king
				if rank:
					return WHITE_STARTING_RANK
				else:
					return Piece.Alliance.WHITE
		Piece.Alliance.BLACK:
			if opposite:
				if king:
					return white_king
				if rank:
					return WHITE_STARTING_RANK
				else:
					return Piece.Alliance.WHITE
			else:
				if king:
					return black_king
				if rank:
					return BLACK_STARTING_RANK
				else:
					return Piece.Alliance.BLACK

func access_state(piece_position):
	if not (STARTING_INDEX_OF_LENGTH <= piece_position[0] and piece_position[0] <= NUM_OF_SQUARES_IN_LENGTH):
		return "Out Of Range!"
	if not (STARTING_INDEX_OF_LENGTH <= piece_position[1] and piece_position[1] <= NUM_OF_SQUARES_IN_LENGTH):
		return "Out Of Range!"
	return board_state[piece_position]

func assign_state(piece, piece_position):
	if piece_position == null:
		print("ERROR", piece.piece_type)
	board_state[piece_position] = piece

func create_piece(piece_alliance, piece_type, piece_position):
	var piece
	var node_reference = gui_piece.instance()
	get_node("../Pieces").add_child(node_reference)
	match piece_type:
		Piece.Type.KING:
			piece = Piece.King.new(node_reference, piece_alliance, piece_position)
		Piece.Type.QUEEN:
			piece = Piece.Queen.new(node_reference, piece_alliance, piece_position)
		Piece.Type.ROOK:
			piece = Piece.Rook.new(node_reference, piece_alliance, piece_position)
		Piece.Type.BISHOP:
			piece = Piece.Bishop.new(node_reference, piece_alliance, piece_position)
		Piece.Type.KNIGHT:
			piece = Piece.Knight.new(node_reference, piece_alliance, piece_position)
		Piece.Type.PAWN:
			piece = Piece.Pawn.new(node_reference, piece_alliance, piece_position)
	assign_state(piece, piece.piece_position)
	node_reference.params(piece)
	
	return piece 

func delete_piece(piece):
	assign_state(null, piece.piece_position)
	piece.node_reference.queue_free()
	piece.queue_free()

func compile_all_pieces():
	all_active_pieces = []
	for piece in board_state.values():
		if piece != null:
			all_active_pieces.append(piece)

func compile_all_legal_moves(alliance):
	var legal_moves = []
	var pseudo_moves = compile_all_pseudo_moves(alliance)
	for move in pseudo_moves:
		move.validate_move(self)
		match move.status:
			Move.Status.LEGAL:
				legal_moves.append(move)
			Move.Status.ILLEGAL:
				pass
	match alliance:
		Piece.Alliance.WHITE:
			white_legal_moves = legal_moves
		Piece.Alliance.BLACK:
			black_legal_moves = legal_moves

func compile_all_pseudo_moves(alliance, exclude_king = false):
	var pseudo_moves = []
	for piece in all_active_pieces:
		if piece.piece_alliance == alliance:
			if exclude_king and piece.piece_type == Piece.Type.KING:
				continue
			pseudo_moves.append_array(piece.compile_pseudo_moves(self))
	return pseudo_moves

func empty_board_state():
	board_state = {}
	for rank in range(STARTING_INDEX_OF_LENGTH, NUM_OF_SQUARES_IN_LENGTH + 1):
		for file in range(STARTING_INDEX_OF_LENGTH, NUM_OF_SQUARES_IN_LENGTH + 1):
			board_state[Vector2(file, rank)] = null

func standard_board_state():
	alliance_turn = Piece.Alliance.WHITE
	create_piece(Piece.Alliance.WHITE, Piece.Type.ROOK, Vector2(1,1))
	create_piece(Piece.Alliance.WHITE, Piece.Type.KNIGHT, Vector2(2,1))
	#create_piece(Piece.Alliance.WHITE, Piece.Type.BISHOP, Vector2(3,1))
	create_piece(Piece.Alliance.WHITE, Piece.Type.QUEEN, Vector2(4,1))
	white_king = create_piece(Piece.Alliance.WHITE, Piece.Type.KING, Vector2(5,1))
	#create_piece(Piece.Alliance.WHITE, Piece.Type.BISHOP, Vector2(6,1))
	create_piece(Piece.Alliance.WHITE, Piece.Type.KNIGHT, Vector2(7,1))
	create_piece(Piece.Alliance.WHITE, Piece.Type.ROOK, Vector2(8,1))
	
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(1,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(2,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(3,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(4,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(5,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(6,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(7,2))
	create_piece(Piece.Alliance.WHITE, Piece.Type.PAWN, Vector2(8,2))
	
	create_piece(Piece.Alliance.BLACK, Piece.Type.ROOK, Vector2(1,8))
	create_piece(Piece.Alliance.BLACK, Piece.Type.KNIGHT, Vector2(2,8))
	#create_piece(Piece.Alliance.BLACK, Piece.Type.BISHOP, Vector2(3,8))
	create_piece(Piece.Alliance.BLACK, Piece.Type.QUEEN, Vector2(4,8))
	black_king = create_piece(Piece.Alliance.BLACK, Piece.Type.KING, Vector2(5,8))
	#create_piece(Piece.Alliance.BLACK, Piece.Type.BISHOP, Vector2(6,8))
	create_piece(Piece.Alliance.BLACK, Piece.Type.KNIGHT, Vector2(7,8))
	create_piece(Piece.Alliance.BLACK, Piece.Type.ROOK, Vector2(8,8))
	
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(1,4))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(2,7))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(3,4))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(4,7))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(5,4))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(6,7))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(7,4))
	create_piece(Piece.Alliance.BLACK, Piece.Type.PAWN, Vector2(8,7))

func debug_print(moves = []):
	var debug_board = [[],[],[],[],[],[],[],[]]
	var index = 0
	for piece in board_state.values():
		# print(board_state.values().size())
		if debug_board[index].size() == NUM_OF_SQUARES_IN_LENGTH:
			index += 1
		if piece == null:
			debug_board[index].append("-")
		else:
			debug_board[index].append(piece.compute_symbol())
	for move in moves:
		var square = move.destination
		if move is Move.Capture:
			debug_board[square[1] - 1][square[0] - 1] = "*"
		else:
			debug_board[square[1] - 1][square[0] - 1] = "~"
	debug_board.invert()
	for line in debug_board:
		print(line)
	print()
