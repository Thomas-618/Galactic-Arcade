extends Node

class Move extends Node:

	var status
	
	var origin
	var destination
	
	enum Status {LEGAL, ILLEGAL}
	
	func _init(origin = null, destination = null):
		self.origin = origin
		self.destination = destination
	
	func execute_move(main):
		var moved_piece = main.access_state(self.origin)
		moved_piece.piece_position = self.destination
		moved_piece.is_first_move = false
		main.assign_state(null, self.origin)
		main.assign_state(moved_piece, self.destination)
		main.alliance_turn = main.derive_alliance(main.alliance_turn, false, false, true)
		main.compile_all_legal_moves(main.alliance_turn)
		main.en_passant = null
		
		moved_piece.node_reference.temp_func()
	
	func validate_move(main):
		var moved_piece = main.access_state(self.origin)
		moved_piece.piece_position = self.destination
		main.assign_state(moved_piece, self.destination)
		main.assign_state(null, self.origin)
		var opponent_moves = main.compile_all_pseudo_moves(main.derive_alliance(main.alliance_turn, false, false, true))
		for move in opponent_moves:
			if move is Capture:
				if main.access_state(move.destination).piece_type == main.Piece.Type.KING:
					self.status =  Status.ILLEGAL
					moved_piece.piece_position = self.origin
					main.assign_state(moved_piece, self.origin)
					main.assign_state(null, self.destination)
					return
		self.status =  Status.LEGAL
		moved_piece.piece_position = self.origin
		main.assign_state(moved_piece, self.origin)
		main.assign_state(null, self.destination)
	
	func print_class():
		print(" + Base Move")
		return 0
	
	class Capture extends Move:
		
		var capture_position
		
		func _init(origin = null, destination = null, capture_position = null).(origin, destination):
			self.capture_position = capture_position
		
		func execute_move(main):
			var moved_piece = main.access_state(self.origin)
			moved_piece.piece_position = self.destination
			moved_piece.is_first_move = false
			main.delete_piece(main.access_state(self.capture_position))
			main.assign_state(null, self.origin)
			main.assign_state(moved_piece, self.destination)
			main.alliance_turn = main.derive_alliance(main.alliance_turn, false, false, true)
			main.compile_all_pieces()
			main.compile_all_legal_moves(main.alliance_turn)
			main.en_passant = null
			
			moved_piece.node_reference.temp_func()
		
		func validate_move(main):
			var moved_piece = main.access_state(self.origin)
			var captured_piece = main.access_state(self.destination)
			moved_piece.piece_position = self.destination
			main.assign_state(moved_piece, self.destination)
			main.assign_state(null, self.origin)
			main.compile_all_pieces()
			var opponent_moves = main.compile_all_pseudo_moves(main.derive_alliance(main.alliance_turn, false, false, true))
			for move in opponent_moves:
				if move is Capture:
					if main.access_state(move.destination).piece_type == main.Piece.Type.KING:
						self.status =  Status.ILLEGAL
						moved_piece.piece_position = self.origin
						main.assign_state(moved_piece, self.origin)
						main.assign_state(captured_piece, self.destination)
						main.compile_all_pieces()
						return
			self.status =  Status.LEGAL
			moved_piece.piece_position = self.origin
			main.assign_state(moved_piece, self.origin)
			main.assign_state(captured_piece, self.destination)
			main.compile_all_pieces()
	
		func print_class():
			print(" + Capture Move")
			return 1
	
	class Castle extends Move:
		enum Castling {KING_SIDE, QUEEN_SIDE}
		var castling_side
		
		func _init(origin = null, destination = null, castling_side = null).(origin, destination):
			self.castling_side = castling_side
		
		func execute_move(main):
			var king_piece = main.access_state(self.origin)
			match self. castling_side:
				Castling.KING_SIDE:
					var rook_piece = main.access_state(Vector2(8, main.derive_alliance(main.alliance_turn, false, true, false)))
					main.assign_state(null, rook_piece.piece_position)
					king_piece.piece_position = Vector2(7, main.derive_alliance(main.alliance_turn, false, true, false))
					rook_piece.piece_position = Vector2(6, main.derive_alliance(main.alliance_turn, false, true, false))
					king_piece.is_first_move = false
					rook_piece.is_first_move = false
					main.assign_state(rook_piece, rook_piece.piece_position)
					rook_piece.node_reference.temp_func()
				Castling.QUEEN_SIDE:
					var rook_piece = main.access_state(Vector2(1, main.derive_alliance(main.alliance_turn, false, true, false)))
					main.assign_state(null, rook_piece.piece_position)
					king_piece.piece_position = Vector2(3, main.derive_alliance(main.alliance_turn, false, true, false))
					rook_piece.piece_position = Vector2(4, main.derive_alliance(main.alliance_turn, false, true, false))
					king_piece.is_first_move = false
					rook_piece.is_first_move = false
					main.assign_state(rook_piece, rook_piece.piece_position)
					rook_piece.node_reference.temp_func()
			main.assign_state(null, self.origin)
			main.assign_state(king_piece, king_piece.piece_position)
			main.alliance_turn = main.derive_alliance(main.alliance_turn, false, false, true)
			main.compile_all_legal_moves(main.alliance_turn)
			main.en_passant = null
			king_piece.node_reference.temp_func()
		
		func validate_move(main):
			self.status =  Status.LEGAL
		
		func print_class():
			print(" + Castle Move")
			return 2
	
	class Pawn_Jump extends Move:
		
		func _init(origin = null, destination = null).(origin, destination):
			pass
		
		func execute_move(main):
			main.en_passant = self.destination
			.execute_move(main)
			main.en_passant = self.destination
		
		func validate_move(main):
			.validate_move(main)
			
		func print_class():
			print(" + Jump Move")
			return 3
	
	class En_Passant extends Capture:
		
		func _init(origin = null, destination = null, capture_position = null).(origin, destination, capture_position):
			pass
		
		func execute_move(main):
			main.en_passant = self.destination
			.execute_move(main)
			main.en_passant = self.destination
		
		func validate_move(main):
			.validate_move(main)
			
		func print_class():
			print(" + Jump Move")
			return 4
			return 4
