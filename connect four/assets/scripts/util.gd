# Stores helpful utilities/helper functions for other scripts.
extends Node
# Class References!
onready var main := $"../Main"
# Data Types!
enum Error {NULL, OUT_OF_RANGE}
# Important Constants!
const STARTING_COORD_OF_BOARD_LENGTH := 1
const BOARD_WIDTH := 7
const BOARD_HEIGHT := 6
const BLACK_STARTING_RANK := 1
const RED_STARTING_RANK := 8
# ----- ----- ----- ----- -----

# Initializes the main.board_state data structure.
func create_board_state():
	main.board_state = Dictionary()
	for row in range(BOARD_HEIGHT, STARTING_COORD_OF_BOARD_LENGTH - 1, -1):
		for column in range(STARTING_COORD_OF_BOARD_LENGTH, BOARD_WIDTH + 1):
			main.board_state[Vector2(column, row)] = null
# ----- ----- ----- ----- -----

# Returns the opposite alliance of what was recieved.
func get_opponent_alliance(alliance):
	match alliance:
		main.Piece.Alliance.RED:
			return main.Piece.Alliance.YELLOW
		main.Piece.Alliance.YELLOW:
			return main.Piece.Alliance.RED
# ----- ----- ----- ----- -----

# Returns the appropriate symbol of a piece, for debugging purposes.
func compute_symbol(piece):
		var symbol
		match piece.piece_alliance:
			main.Piece.Alliance.RED:
				symbol = "R"
			main.Piece.Alliance.YELLOW:
				symbol = "Y"
			_:
				symbol = "-"
		return symbol

# Returns the file address of the sprite in memory.
func compute_sprite_address(piece, feedback = false):
	var sprite_address
	match piece.piece_alliance:
		0:
			sprite_address = "red"
		1:
			sprite_address = "yellow"
	if feedback:
		sprite_address = "res://connect four/assets/sprites/%s/feedback/chip.png" % sprite_address
	else:
		sprite_address = "res://connect four/assets/sprites/%s/chip.png" % sprite_address
	return load(sprite_address)
# ----- ----- ----- ----- -----

# Prints the internatl main.board_state to the console to debug.
func debug_print():
	var debug_board = [[],[],[],[],[],[]]
	var index = 0
	for position in main.board_state.values():
		if debug_board[index].size() == BOARD_WIDTH:
			index += 1
		if position == null:
			debug_board[index].append("-")
		else:
			debug_board[index].append(compute_symbol(position))
	for line in debug_board:
		print(line)
	print()
