# Stores all necessary logic for making and simulating moves.
extends Node
# Blueprint for a basic checker move.
class Move:
	# Script Reference!
	var main #: Node
	# Data Types!
	enum Status {LEGAL, ILLEGAL}
	# Member Variables!
	var move_piece #: Piece
	var move_origin #: Vector2
	var move_destination #: Vector2
	var move_status #: Status
	# ----- ----- ----- ----- -----
	
	# Initialize an instance of the Move class.
	func _init(main = null, move_piece = null, 
			   move_origin = null, move_destination = null, move_status = null):
		self.main = main
		self.move_piece = move_piece
		self.move_origin = move_origin
		self.move_destination = move_destination
		self.move_status = move_status
	
	# "Executes" or makes a move to the main.board_state
	func execute_move():
		main.recent_move = self
		main.alter_state(self.move_origin, null)
		main.alter_state(self.move_destination, self.move_piece)
		main.next_turn()
	# ----- ----- ----- ----- -----
	
	# Blueprint for a basic capture move.
	class Capture extends Move:
		# Member Variables!
		var capture_piece #: Piece
		
		# Initialize an instance of the Capture move class
		func _init(main = null, move_piece = null, capture_piece = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
			self.capture_piece = capture_piece
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			main.delete_piece(self.capture_piece)
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.next_turn()
	# ----- ----- ----- ----- -----
	
	# Blueprint for a pawn promotion move.
	class Promotion extends Move:
		# Data Types!
		enum Move_Type {BASE_MOVE, CAPTURE_MOVE}
		# Member Variables!
		var move_type #: Move
		var capture_piece #: Piece
		
		# Initializes an instance of the Pawn_Promotion move class.
		func _init(main = null, move_piece = null, move_type = null, path_state = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
			self.move_type = move_type
			if self.move_type == Move_Type.CAPTURE_MOVE:
				capture_piece = path_state
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			if self.move_type == Move_Type.CAPTURE_MOVE:
				main.delete_piece(capture_piece)
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.delete_piece(self.move_piece)
			main.create_piece(self.move_piece.piece_alliance, main.Piece.Type.KING, 
							  self.move_piece.piece_position)
			main.update_active_pieces()
			main.next_turn()
	# ----- ----- ----- ----- -----
