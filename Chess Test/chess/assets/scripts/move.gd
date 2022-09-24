# Comment on file purpose.
extends Node
# Comment on class purpose.
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
	
	# Comment on function purpose.
	func _init(main = null, move_piece = null, 
			   move_origin = null, move_destination = null, move_status = null):
		self.main = main
		self.move_piece = move_piece
		self.move_origin = move_origin
		self.move_destination = move_destination
		self.move_status = move_status
	
	# Comment on function purpose.
	func execute_move():
		self.move_piece.piece_moved = true
		main.alter_state(self.move_origin, null)
		main.alter_state(self.move_destination, self.move_piece)
		main.en_passant_pawn = null
		main.next_turn()
	
	# Comment on function purpose.
	func apply_move():
		self.save_piece_moved_bool = self.move_piece.piece_moved
		self.save_en_passant_pawn = main.en_passant_pawn
		self.move_piece.piece_moved = true
		main.alter_state(self.move_origin, null)
		main.alter_state(self.move_destination, self.move_piece)
		main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
		main.en_passant_pawn = null
	
	# Comment on function purpose.
	func unapply_move():
		self.move_piece.piece_moved = save_piece_moved_bool
		main.alter_state(self.move_origin, self.move_piece)
		main.alter_state(self.move_destination, null)
		main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
		main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Comment on class purpose.
	class Capture extends Move:
		# Member Variables!
		var capture_piece #: Piece
		
		# Comment on function purpose.
		func _init(main = null, move_piece = null, 
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# Comment on function purpose.
		func execute_move():
			main.delete_piece(self.capture_piece)
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = null
			main.next_turn()
		
		# Comment on function purpose.
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
		
		# Comment on function purpose.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, self.capture_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Comment on class purpose.
	class Castle extends Move:
		# Data Types!
		enum Castling {KING_SIDE, QUEEN_SIDE}
		# Member Variables!
		var castle_piece #: Piece
		var castling_side #: Castling
		var save_castle_piece_moved_bool #: bool
		
		# Comment on function purpose.
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
		
		# Comment on function purpose.
		func execute_move():
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
			main.util.debug_print()

		
		# Comment on function purpose.
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
		
		# Comment on function purpose.
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
	
	# Comment on class purpose.
	class Pawn_Promotion extends Move:
		# Data Types!
		enum Move_Type {BASE_MOVE, CAPTURE_MOVE}
		# Member Variables!
		var move_type #: Move
		var capture_piece #: Piece
		
		# Comment on function purpose.
		func _init(main = null, move_piece = null, move_type = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
			self.move_type = move_type
		
		# Comment on function purpose.
		func execute_move():
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
		
		# Comment on function purpose.
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
		
		# Comment on function purpose.
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
	
	# Comment on class purpose.
	class Pawn_Jump extends Move:
		
		# Comment on function purpose.
		func _init(main = null, move_piece = null, 
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# Comment on function purpose.
		func execute_move():
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = self.move_piece
			main.next_turn()
		
		# Comment on function purpose.
		func apply_move():
			self.save_piece_moved_bool = self.move_piece.piece_moved
			self.save_en_passant_pawn = main.en_passant_pawn
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = self.move_piece
		
		# Comment on function purpose.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, null)
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
	
	# Comment on class purpose.
	class En_Passant extends Capture:
		
		# Comment on function purpose.
		func _init(main = null, move_piece = null,
				   move_origin = null, move_destination = null, move_status = null):
			._init(main, move_piece, move_origin, move_destination, move_status)
		
		# Comment on function purpose.
		func execute_move():
			main.delete_piece(main.access_state(main.en_passant_pawn.piece_position))
			self.move_piece.piece_moved = true
			main.alter_state(self.move_origin, null)
			main.alter_state(self.move_destination, self.move_piece)
			main.en_passant_pawn = null
			main.next_turn()
		
		# Comment on function purpose.
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
		
		# Comment on function purpose.
		func unapply_move():
			self.move_piece.piece_moved = save_piece_moved_bool
			main.alter_state(self.move_origin, self.move_piece)
			main.alter_state(self.move_destination, self.capture_piece)
			main.update_active_pieces()
			main.alliance_turn = main.util.get_opponent_alliance(main.alliance_turn)
			main.en_passant_pawn = save_en_passant_pawn
	# ----- ----- ----- ----- -----
