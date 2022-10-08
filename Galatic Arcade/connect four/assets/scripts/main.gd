# Stores logic for the main functioning of the program.
# (calls the other scripts)
extends Node
# Class/Script references!
onready var Piece = $"../Piece".Piece
onready var Piece_Gui = preload("res://connect four/assets/scenes/piece_gui.tscn")
onready var test = $"../Test"
onready var util = $"../Util"
# Data Types!
enum Game_State {ONGOING, OVER}
enum Alliance {RED, YELLOW}
# Member Variables!
var game_state #: Game_State
var alliance_turn #: Alliance
var board_state #: Dictionary
var cooldown = true
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
	alliance_turn = Piece.Alliance.RED
	for column in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH + 1):
		var node = get_node("../../Board/%s/Area_2D" % column)
		node.connect("input_event", self, "_input_event", [node])
	# test.set_promotion_test_board_state()
	util.debug_print()

# Progresses to the next turn, calling necessary functions to check for win conditions.
func next_turn():
	alliance_turn = util.get_opponent_alliance(alliance_turn)
	assess_state()
	yield(get_tree().create_timer(0.25), "timeout")
	cooldown = true

# Alters the board_state at a certain position and setting the value to the alteration.
func alter_state(position: Vector2, alteration):
	if position == null:
		return util.Error.NULL
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[0] and 
			position[0] <= util.BOARD_WIDTH):
		return util.Error.OUT_OF_RANGE
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[1] and 
			position[1] <= util.BOARD_HEIGHT):
		return util.Error.OUT_OF_RANGE
	board_state[position] = alteration
	if alteration is Piece:
		alteration.piece_position = position

# Accesses the board_state and returns the value at the position.
func access_state(position):
	if position == null:
		return util.Error.NULL
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[0] and 
			position[0] <= util.BOARD_WIDTH):
		return util.Error.OUT_OF_RANGE
	if not (util.STARTING_COORD_OF_BOARD_LENGTH <= position[1] and 
			position[1] <= util.BOARD_HEIGHT):
		return util.Error.OUT_OF_RANGE
	return board_state[position]

# Assesses the board_state checking for win conditions.
func assess_state():
	util.debug_print()
	var connect = []
	connect.append_array(check_horizontal_connect())
	connect.append_array(check_vertical_connect())
	connect.append_array(check_positive_diagonal_connect())
	connect.append_array(check_negative_diagonal_connect())
	for piece in connect:
		piece.piece_gui.feedback_indicator(true)
	game_state = Game_State.ONGOING
	if connect.size() > 0:
		game_state = Game_State.OVER

	
# ----- ----- ----- ----- -----

# A helper function to assess_state, which checks for a horizontal connect-four.
func check_horizontal_connect():
	var connect
	for row in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT + 1):
		for column in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH + 1):
			connect = Array()
			connect.append(access_state(Vector2(column, row)))
			if not (connect[0] is Piece):
				continue
			for connect_length in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH):
				connect.append(access_state(Vector2(column + connect_length, row)))
				if ( not (connect[-1] is Piece) or 
					 connect[0].piece_alliance != connect[-1].piece_alliance
					):
					connect.pop_back()
					if connect_length >= 4:
						return connect
					else:
						break
	return []

# A helper function to assess_state, which checks for a vertical connect-four.
func check_vertical_connect():
	var connect
	for column in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH + 1):
		for row in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT + 1):
			connect = Array()
			connect.append(access_state(Vector2(column, row)))
			if not (connect[0] is Piece):
				continue
			for connect_length in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT):
				connect.append(access_state(Vector2(column, row + connect_length)))
				if ( not (connect[-1] is Piece) or 
					 connect[0].piece_alliance != connect[-1].piece_alliance
					):
					connect.pop_back()
					if connect_length >= 4:
						return connect
					else:
						break
	return []

# A helper function to assess_state, which checks for a diagonal connect-four (with a positive slope).
func check_positive_diagonal_connect():
	var connect
	for row in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT + 1):
		for column in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH + 1):
			connect = Array()
			connect.append(access_state(Vector2(column, row)))
			if not (connect[0] is Piece):
				continue
			for connect_length in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH):
				connect.append(access_state(Vector2(column + connect_length, row + connect_length)))
				if ( not (connect[-1] is Piece) or 
					 connect[0].piece_alliance != connect[-1].piece_alliance
					):
					connect.pop_back()
					if connect_length >= 4:
						return connect
					else:
						break
	return []

# A helper function to assess_state, which checks for a diagonal connect-four (with a negative slope).
func check_negative_diagonal_connect():
	var connect
	for row in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT + 1):
		for column in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH + 1):
			connect = Array()
			connect.append(access_state(Vector2(column, row)))
			if not (connect[0] is Piece):
				continue
			for connect_length in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_WIDTH):
				connect.append(access_state(Vector2(column + connect_length, row - connect_length)))
				if ( not (connect[-1] is Piece) or 
					 connect[0].piece_alliance != connect[-1].piece_alliance
					):
					connect.pop_back()
					if connect_length >= 4:
						return connect
					else:
						break
	return []
# ----- ----- ----- ----- -----

# Creates a piece, including the a Piece class instance and an instance of the piece_gui.
func create_piece(piece_alliance, piece_position):
	for row in range(util.STARTING_COORD_OF_BOARD_LENGTH, util.BOARD_HEIGHT + 1):
		if access_state(Vector2(piece_position, row)) == null:
			piece_position = Vector2(piece_position, row)
			break
	var piece_gui = Piece_Gui.instance()
	var piece = Piece.new(self, piece_gui, piece_alliance, piece_position)
	alter_state(piece_position, piece)
	piece_gui.init(self, piece)
	$"../../Pieces".add_child(piece_gui)
	return piece 
# ----- ----- ----- ----- -----

# Game logic for handling user input in the GUI.
func _input_event(_viewport, _event, _shape_idx, node):
	if not cooldown:
		return
	if Input.is_action_just_pressed("ui_click"):
		cooldown = false
		create_piece(alliance_turn, node.global_position[0] / 73 + 1)
		next_turn()
