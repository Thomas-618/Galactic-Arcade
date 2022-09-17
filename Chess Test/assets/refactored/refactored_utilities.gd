# Comment on file purpose.
extends Node
# Class References!
onready var main := get_parent()
# Data Types!
enum Error {NULL, OUT_OF_RANGE}
# Important Constants!
const STARTING_COORD_OF_BOARD_LENGTH := 1
const ENDING_COORD_OF_BOARD_LENGTH := 8
const DEFAULT_KING_POSITION := 5
const DEFAULT_KING_SIDE_ROOK_POSITION := 8
const DEFAULT_QUEEN_SIDE_ROOK_POSITION := 1
const KING_SIDE_CASTLING_KING_POSITION := 7
const KING_SIDE_CASTLING_ROOK_POSITION := 6
const QUEEN_SIDE_CASTLING_KING_POSITION := 3
const QUEEN_SIDE_CASTLING_ROOK_POSITION := 4
const KING_SIDE_CASTLING_PATH := [6, 7]
const QUEEN_SIDE_CASTLING_PATH := [4, 3]
const WHITE_STARTING_RANK := 1
const BLACK_STARTING_RANK := 8
# ----- ----- ----- ----- -----

# Comment on function purpose.
func create_board_state():
	main.board_state = Dictionary()
	for row in range(ENDING_COORD_OF_BOARD_LENGTH, STARTING_COORD_OF_BOARD_LENGTH - 1, -1):
		for column in range(STARTING_COORD_OF_BOARD_LENGTH, ENDING_COORD_OF_BOARD_LENGTH + 1):
			main.board_state[Vector2(column, row)] = null

# Comment on function purpose.
func set_standard_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(1,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KNIGHT, Vector2(2,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.BISHOP, Vector2(3,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.QUEEN,  Vector2(4,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.BISHOP, Vector2(6,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KNIGHT, Vector2(7,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(8,1))
	
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(1,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(2,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(3,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(4,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(5,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(6,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(7,2))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN, Vector2(8,2))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(1,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KNIGHT, Vector2(2,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.BISHOP, Vector2(3,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.QUEEN,  Vector2(4,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.BISHOP, Vector2(6,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KNIGHT, Vector2(7,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(8,8))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(1,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(2,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(3,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(4,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(5,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(6,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(7,7))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(8,7))
	main.update_active_pieces()
	main.move_record = []
	main.en_passant_pawn = null
	main.next_turn()

# Comment on function purpose.
func get_opponent_alliance(alliance):
	match alliance:
		main.Piece.Alliance.WHITE:
			return main.Piece.Alliance.BLACK
		main.Piece.Alliance.BLACK:
			return main.Piece.Alliance.WHITE

# Comment on function purpose.
func get_starting_rank(alliance):
	match alliance:
		main.Piece.Alliance.WHITE:
			return WHITE_STARTING_RANK 
		main.Piece.Alliance.BLACK:
			return BLACK_STARTING_RANK

# Comment on function purpose.
func debug_print():
	var debug_board = [[],[],[],[],[],[],[],[]]
	var index = 0
	for position in main.board_state.values():
		if debug_board[index].size() == ENDING_COORD_OF_BOARD_LENGTH:
			index += 1
		if position == null:
			debug_board[index].append("-")
		else:
			debug_board[index].append(position.compute_symbol())
	for line in debug_board:
		print(line)
	print()
