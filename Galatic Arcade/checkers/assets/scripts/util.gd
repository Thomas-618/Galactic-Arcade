# Stores helpful utilities/helper functions for other scripts.
extends Node
# Class References!
onready var main := $"../Main"
# Data Types!
enum Error {NULL, OUT_OF_RANGE}
# Important Constants!
const STARTING_COORD_OF_BOARD_LENGTH := 1
const ENDING_COORD_OF_BOARD_LENGTH := 8
const BLACK_STARTING_RANK := 1
const RED_STARTING_RANK := 8
# ----- ----- ----- ----- -----

# Initializes the main.board_state data structure.
func create_board_state():
	main.board_state = Dictionary()
	for row in range(ENDING_COORD_OF_BOARD_LENGTH, STARTING_COORD_OF_BOARD_LENGTH - 1, -1):
		for column in range(STARTING_COORD_OF_BOARD_LENGTH, ENDING_COORD_OF_BOARD_LENGTH + 1):
			main.board_state[Vector2(column, row)] = null

# Creates the necessary pieces for the default chess board starting state.
func set_standard_board_state():
	main.alliance_turn = main.Piece.Alliance.RED # next_turn() is called to start with the black.
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(1, 1))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(3, 1))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(5, 1))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(7, 1))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(2, 2))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(4, 2))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(6, 2))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(8, 2))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(1, 3))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(3, 3))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(5, 3))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(7, 3))
	
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(2, 8))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(4, 8))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(6, 8))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(8, 8))
	 
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(1, 7))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(3, 7))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(5, 7))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(7, 7))
	
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(2, 6))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(4, 6))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(6, 6))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(8, 6))
	main.update_active_pieces()
	main.game_state = main.Game_State.ONGOING
	main.next_turn()
# ----- ----- ----- ----- -----

# Returns the opposite alliance of what was recieved.
func get_opponent_alliance(alliance):
	match alliance:
		main.Piece.Alliance.BLACK:
			return main.Piece.Alliance.RED
		main.Piece.Alliance.RED:
			return main.Piece.Alliance.BLACK

# Returns the starting rank for the alliance.
func get_starting_rank(alliance):
	match alliance:
		main.Piece.Alliance.BLACK:
			return BLACK_STARTING_RANK 
		main.Piece.Alliance.RED:
			return RED_STARTING_RANK
# ----- ----- ----- ----- -----

# Returns the appropriate symbol of a piece, for debugging purposes.
func compute_symbol(piece):
		var symbol
		match piece.piece_type:
			main.Piece.Type.KING:
				symbol = "K"
			main.Piece.Type.PAWN:
				symbol = "P"
			_:
				symbol = "-"
		if piece.piece_alliance == main.Piece.Alliance.BLACK:
			return symbol.to_upper()
		elif piece.piece_alliance == main.Piece.Alliance.RED:
			return symbol.to_lower()
		return symbol

# Returns the file address of the sprite in memory.
func compute_sprite_address(piece, feedback = false):
	var sprite_address = []
	match piece.piece_alliance:
		0:
			sprite_address.append("black")
		1:
			sprite_address.append("red")
	match piece.piece_type:
		0:
			sprite_address.append("king")
		1:
			sprite_address.append("pawn")
	if feedback:
		sprite_address = "res://checkers/assets/sprites/pieces/%s/feedback/%s.png" % sprite_address
	else:
		sprite_address = "res://checkers/assets/sprites/pieces/%s/%s.png" % sprite_address
	return load(sprite_address)
# ----- ----- ----- ----- -----

# Prints the internatl main.board_state to the console to debug.
func debug_print():
	var debug_board = [[],[],[],[],[],[],[],[]]
	var index = 0
	for position in main.board_state.values():
		if debug_board[index].size() == ENDING_COORD_OF_BOARD_LENGTH:
			index += 1
		if position == null:
			debug_board[index].append("-")
		else:
			debug_board[index].append(compute_symbol(position))
	for line in debug_board:
		print(line)
	print()
