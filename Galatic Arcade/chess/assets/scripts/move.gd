# Stores all necessary logic for making and simulating moves.
extends Node
# Blueprint for a basic chess move.
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
	var save_piece_moved_bool #: bool
	var save_en_passant_pawn #: Piece
	# ----- ----- ----- ----- -----
	
	# Code in some places may be inefficient or make unnessary actions at times. 
	# This is a result of vestiges of old purposing of the code. 
	# (The original intent of the program was to have an AI player option).
	# All code is functional
	
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
		self.move_piece.piece_moved = true
		main.alter_state(self.move_origin, null)
		main.alter_state(self.move_destination, self.move_piece)
		main.en_passant_pawn = null
		main.next_turn()
	
	# Temporarily makes a move to the main.board_state in order to see the result.
	# (prevents illegal moves)
	func apply_move():
		self.save_piece_moved_bool = self.move_piece.piece_moved
		self.save_en_passant_pawn = main.en_passant_pawn
		self.move_piece.piece_moved = true
		main.alter_state(self.move_origin, null)
		main.alter_state(self.move_destination, self.move_piece)
		main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
		main.en_passant_pawn = null
	
	# Undos a previously applied move, to set the main.board_state back to the previous position.
	func unapply_move():
		self.move_piece.piece_moved = save_piece_moved_bool
		main.alter_state(self.move_origin, self.move_piece)
		main.alter_state(self.move_destination, null)
		main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
		main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Blueprint for a basic capture move.
	class Capture extends Move:
		# Member Variables!
		var capture_piece #: Piece
		
		# Initialize an instance of the Capture move class
		func _init(main = null, move_piece = null, 
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			main.delete_piece(self.capture_piece)
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = null
			main.next_turn()
		
		# Temporarily makes a move to the main.board_state in order to see the result.
		# (prevents illegal moves)
		func apply_move():
			self.capture_piece = main.access_state(self.move_destination)
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = null
		
		# Undos a previously applied move, to set the main.board_state back to the previous position.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, self.capture_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Blueprint for a castling move, both king and queen side.
	class Castle extends Move:
		# Data Types!
		enum Castling {KING_SIDE, QUEEN_SIDE}
		# Member Variables!
		var castle_piece #: Piece
		var castling_side #: Castling
		var save_castle_piece_moved_bool #: bool
		
		# Initializes and instance of the Castle move class.
		func _init(main = null, king_piece = null, rook_piece = null, 
				   castling_side = null, move_status = null):
			self.castle_piece = rook_piece
			self.castling_side = castling_side
			if self.castling_side == Castling.KING_SIDE:
				._init(main, king_piece, king_piece.piece_position, 
					   Vector2(main.util.KING_SIDE_CASTLING_KING_POSITION, 
							   main.util.get_starting_rank(king_piece.piece_alliance)), move_status)
			elif self.castling_side == Castling.QUEEN_SIDE:
				._init(main, king_piece, king_piece.piece_position, 
					   Vector2(main.util.QUEEN_SIDE_CASTLING_KING_POSITION, 
							   main.util.get_starting_rank(king_piece.piece_alliance)), move_status)
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			var CASTLING_KING_POSITION
			var CASTLING_ROOK_POSITION
			if self.castling_side == Castling.KING_SIDE:
				CASTLING_KING_POSITION = Vector2(main.util.KING_SIDE_CASTLING_KING_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
				CASTLING_ROOK_POSITION = Vector2(main.util.KING_SIDE_CASTLING_ROOK_POSITION,
										main.util.get_starting_rank(main.alliance_turn))
			elif self.castling_side == Castling.QUEEN_SIDE:
				CASTLING_KING_POSITION = Vector2(main.util.QUEEN_SIDE_CASTLING_KING_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
				CASTLING_ROOK_POSITION = Vector2(main.util.QUEEN_SIDE_CASTLING_ROOK_POSITION,
										main.util.get_starting_rank(main.alliance_turn))
			main.alter_state(self.move_piece.piece_position, null)
			main.alter_state(CASTLING_KING_POSITION, self.move_piece)
			self.move_piece.piece_moved = true
			main.alter_state(self.castle_piece.piece_position, null)
			main.alter_state(CASTLING_ROOK_POSITION, self.castle_piece)
			self.castle_piece.piece_moved = true
			main.en_passant_pawn = null
			self.castle_piece.piece_gui.update_gui()
			main.next_turn()
		
		
		# Temporarily makes a move to the main.board_state in order to see the result.
		# (prevents illegal moves)
		func apply_move():
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_castle_piece_moved_bool = castle_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			var CASTLING_KING_POSITION
			var CASTLING_ROOK_POSITION
			if self.castling_side == Castling.KING_SIDE:
				CASTLING_KING_POSITION = Vector2(main.util.KING_SIDE_CASTLING_KING_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
				CASTLING_ROOK_POSITION = Vector2(main.util.KING_SIDE_CASTLING_ROOK_POSITION,
										main.util.get_starting_rank(main.alliance_turn))
			elif self.castling_side == Castling.QUEEN_SIDE:
				CASTLING_KING_POSITION = Vector2(main.util.QUEEN_SIDE_CASTLING_KING_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
				CASTLING_ROOK_POSITION = Vector2(main.util.QUEEN_SIDE_CASTLING_ROOK_POSITION,
										main.util.get_starting_rank(main.alliance_turn))
			main.alter_state(self.move_piece.piece_position, null)
			main.alter_state(CASTLING_KING_POSITION, self.move_piece)
			self.move_piece.piece_moved = true
			main.alter_state(self.castle_piece.piece_position, null)
			main.alter_state(CASTLING_ROOK_POSITION, self.castle_piece)
			self.castle_piece.piece_moved = true
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = null
		
		# Undos a previously applied move, to set the main.board_state back to the previous position.
		func unapply_move():
			var DEFAULT_ROOK_POSITION
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			if self.castling_side == Castling.KING_SIDE:
				DEFAULT_ROOK_POSITION = Vector2(main.util.DEFAULT_KING_SIDE_ROOK_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
			elif self.castling_side == Castling.QUEEN_SIDE:
				DEFAULT_ROOK_POSITION = Vector2(main.util.DEFAULT_QUEEN_SIDE_ROOK_POSITION, 
										main.util.get_starting_rank(main.alliance_turn))
			main.alter_state(self.move_piece.piece_position, null)
			var DEFAULT_KING_POSITION = Vector2(main.util.DEFAULT_KING_POSITION, 
											  main.util.get_starting_rank(main.alliance_turn))
			main.alter_state(DEFAULT_KING_POSITION, self.move_piece)
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.castle_piece.piece_position, null)
			self.castle_piece.piece_position = DEFAULT_ROOK_POSITION
			main.alter_state(DEFAULT_ROOK_POSITION, self.castle_piece)
			self.castle_piece.piece_moved = save_castle_piece_moved_bool
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Blueprint for a pawn promotion move.
	class Pawn_Promotion extends Move:
		# Data Types!
		enum Move_Type {BASE_MOVE, CAPTURE_MOVE}
		# Member Variables!
		var move_type #: Move
		var capture_piece #: Piece
		
		# Initializes an instance of the Pawn_Promotion move class.
		func _init(main = null, move_piece = null, move_type = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
			self.move_type = move_type
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			if self.move_type == Move_Type.CAPTURE_MOVE:
				main.delete_piece(main.access_state(self.move_destination))
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.delete_piece(self.move_piece)
			main.create_piece(self.move_piece.piece_alliance, main.Piece.Type.QUEEN, 
							  self.move_piece.piece_position, self.move_piece.piece_moved)
			main.update_active_pieces()
			main.en_passant_pawn = null
			main.next_turn()
		
		# Temporarily makes a move to the main.board_state in order to see the result.
		# (prevents illegal moves)
		func apply_move():
			if self.move_type == Move_Type.CAPTURE_MOVE:
				self.capture_piece = main.access_state(self.move_destination)
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			self.move_piece.piece_moved = true
			self.move_piece.piece_type = main.Piece.Type.QUEEN
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = null
		
		# Undos a previously applied move, to set the main.board_state back to the previous position.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			self.move_piece.piece_type = main.Piece.Type.PAWN
			main.alter_state(self.move_origin, self.move_piece)
			if self.move_type == Move_Type.CAPTURE_MOVE:
				main.alter_state(self.move_destination, self.capture_piece)
			elif self.move_type == Move_Type.BASE_MOVE:
				main.alter_state(self.move_destination, null)

			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Blueprint for a pawn double jump move.
	class Pawn_Jump extends Move:
		
		# Initializes an instance of the Pawn_Jump move class.
		func _init(main = null, move_piece = null, 
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = self.move_piece
			main.next_turn()
		
		# Temporarily makes a move to the main.board_state in order to see the result.
		# (prevents illegal moves)
		func apply_move():
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = self.move_piece
		
		# Undos a previously applied move, to set the main.board_state back to the previous position.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, null)
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Blueprint for en passant move
	class En_Passant extends Capture:
		
		# Intializes an instance of the En_Passant move class.
		func _init(main = null, move_piece = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# "Executes" or makes a move to the main.board_state
		func execute_move():
			main.recent_move = self
			main.delete_piece(main.access_state(main.en_passant_pawn.piece_position))
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = null
			main.next_turn()
		
		# Temporarily makes a move to the main.board_state in order to see the result.
		# (prevents illegal moves)
		func apply_move():
			self.capture_piece = main.access_state(self.move_destination)
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = null
		
		# Undos a previously applied move, to set the main.board_state back to the previous position.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, self.capture_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
