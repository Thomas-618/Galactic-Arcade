# Stores all game logic for piece behavior.
extends Node
# Blueprint for a checker piece's behavior.
class Piece:
	# Script Reference!
	var main #: Node
	# Data Types!
	enum Alliance {RED, YELLOW}
	# Member Variables!
	var piece_gui #: Sprite
	var piece_alliance #: Alliance
	var piece_position #: Vector2
	# ----- ----- ----- ----- -----
	
	# Initializes an instance of the piece class.
	func _init(main = null, piece_gui = null, 
			   piece_alliance = null, piece_position = null):
		self.main = main
		self.piece_gui = piece_gui
		self.piece_alliance = piece_alliance
		self.piece_position = piece_position
# ----- ----- ----- ----- -----
class Chip extends Piece:
	
	# Initializes an instance of the chip class.
	func _init(main = null, piece_gui = null, 
			   piece_alliance = null, piece_position = null):
		._init(main, piece_gui, piece_alliance, piece_position)
# ----- ----- ----- ----- -----
