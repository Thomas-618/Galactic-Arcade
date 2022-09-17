extends Node

class Piece extends Node:
	
	var node_reference
	
	var piece_alliance
	var piece_type
	var piece_position
	
	var is_first_move
	
	enum Alliance {WHITE, BLACK}
	enum Type {KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN}
	
	func _init(node_reference = null, piece_alliance = null, piece_type = null, piece_position = null):
		self.node_reference = node_reference
		
		self.piece_alliance = piece_alliance
		self.piece_type = piece_type
		self.piece_position = piece_position
		
		self.is_first_move = true
	
	func compile_pseudo_moves(main):
		pass
	
	func compute_symbol():
		var symbol
		match self.piece_type:
			Type.KING:
				symbol = "K"
			Type.QUEEN:
				symbol = "Q"
			Type.ROOK:
				symbol = "R"
			Type.BISHOP:
				symbol = "B"
			Type.KNIGHT:
				symbol = "N"
			Type.PAWN:
				symbol = "P"
			_:
				symbol = "-"
		if self.piece_alliance == Alliance.WHITE:
			return symbol.to_upper()
		elif self.piece_alliance == Alliance.BLACK:
			return symbol.to_lower()
		return symbol
	
	func evaluate_piece():
		var value
		match self.piece_type:
			Type.KING:
				value = 10000
			Type.QUEEN:
				value = 900
			Type.ROOK:
				value = 500
			Type.BISHOP:
				value = 330
			Type.KNIGHT:
				value = 300
			Type.PAWN:
				value = 100
			_:
				value = 0
		return value
	
	class King extends Piece:
		const MOVEMENT = [Vector2(-1,-1),
						  Vector2(-1,0), 
						  Vector2(-1,1), 
						  Vector2(0,-1), 
						  Vector2(0,1), 
						  Vector2(1,-1),
						  Vector2(1,0),
						  Vector2(1,1)]
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.KING, piece_position):
			pass
		
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if typeof(destination_state) == typeof("Out Of Range"):
					continue
				if destination_state != null:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
				else:
					pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			if not self.is_first_move:
				return pseudo_moves
			for piece in main.all_active_pieces:
				if piece.piece_alliance == self.piece_alliance and piece is Rook and piece.is_first_move:
					if piece.piece_position[0] == 1:
						if not (
							main.access_state(Vector2(2, main.derive_alliance(main.alliance_turn, false, true, false))) == null and
							main.access_state(Vector2(3, main.derive_alliance(main.alliance_turn, false, true, false))) == null and
							main.access_state(Vector2(4, main.derive_alliance(main.alliance_turn, false, true, false))) == null
						):
							return pseudo_moves
						var opponent_moves = main.compile_all_pseudo_moves(main.derive_alliance(main.alliance_turn, false, false, true), true)
						for move in opponent_moves:
							if (
								move.destination == Vector2(2, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(3, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(4, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(5, main.derive_alliance(main.alliance_turn, false, true, false))
							):
								return pseudo_moves
						pseudo_moves.append(main.Move.Castle.new(self.piece_position, null, main.Move.Castle.Castling.KING_SIDE))
					if piece.piece_position[0] == 8:
						if not (
							main.access_state(Vector2(6, main.derive_alliance(main.alliance_turn, false, true, false))) == null and
							main.access_state(Vector2(7, main.derive_alliance(main.alliance_turn, false, true, false))) == null and
							main.access_state(Vector2(8, main.derive_alliance(main.alliance_turn, false, true, false))) == null
						):
							return pseudo_moves
						var opponent_moves = main.compile_all_pseudo_moves(main.derive_alliance(main.alliance_turn, false, false, true), true)
						for move in opponent_moves:
							if (	
								move.destination == Vector2(5, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(6, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(7, main.derive_alliance(main.alliance_turn, false, true, false)) or 
								move.destination == Vector2(8, main.derive_alliance(main.alliance_turn, false, true, false))
								):
								return pseudo_moves
						pseudo_moves.append(main.Move.Castle.new(self.piece_position, null, main.Move.Castle.Castling.QUEEN_SIDE))
			return pseudo_moves
	
	class Queen extends Piece:
		const MOVEMENT = [Vector2(-1,-1),
						  Vector2(-1,0), 
						  Vector2(-1,1), 
						  Vector2(0,-1), 
						  Vector2(0,1), 
						  Vector2(1,-1),
						  Vector2(1,0),
						  Vector2(1,1)]
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.QUEEN, piece_position):
			pass
		
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if typeof(destination_state) == typeof("Out Of Range"):
						break
					if destination_state != null:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
						break
					else:
						pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			return pseudo_moves
	
	class Rook extends Piece:
		const MOVEMENT = [Vector2(-1,0), 
						  Vector2(0,-1), 
						  Vector2(0,1), 
						  Vector2(1,0)]
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.ROOK, piece_position):
			pass
		
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if typeof(destination_state) == typeof("Out Of Range"):
						break
					if destination_state != null:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
						break
					else:
						pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			return pseudo_moves
	
	class Bishop extends Piece:
		const MOVEMENT = [Vector2(-1,-1), 
						  Vector2(-1,1), 
						  Vector2(1,-1), 
						  Vector2(1,1)]
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.BISHOP, piece_position):
			pass
		
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if typeof(destination_state) == typeof("Out Of Range"):
						break
					if destination_state != null:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
						break
					else:
						pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			return pseudo_moves
	
	class Knight extends Piece:
		const MOVEMENT = [Vector2(-2,-1),
						  Vector2(-2,1), 
						  Vector2(-1,-2), 
						  Vector2(-1,2), 
						  Vector2(1,-2),
						  Vector2(1,2),
						  Vector2(2,-1),
						  Vector2(2,1)]
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.KNIGHT, piece_position):
			pass
		
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if typeof(destination_state) == typeof("Out Of Range"):
					continue
				if destination_state != null:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
				else:
					pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			return pseudo_moves
	
	class Pawn extends Piece:
		var MOVEMENT = [Vector2(0,1)]
		var ATTACKING = [Vector2(-1,1), Vector2(1,1)]
		var HEADING
		
		func _init(node_reference, piece_alliance, piece_position).(node_reference, piece_alliance, Type.PAWN, piece_position):
			if piece_alliance == Alliance.WHITE:
				HEADING = 1
				MOVEMENT = [Vector2(MOVEMENT[0][0], HEADING * MOVEMENT[0][1])]
				ATTACKING = [Vector2(ATTACKING[0][0], HEADING * ATTACKING[0][1]), Vector2(ATTACKING[1][0], 1 * ATTACKING[1][1])]
			if piece_alliance == Alliance.BLACK:
				HEADING = -1
				MOVEMENT = [Vector2(MOVEMENT[0][0], HEADING * MOVEMENT[0][1])]
				ATTACKING = [Vector2(ATTACKING[0][0], HEADING * ATTACKING[0][1]), Vector2(ATTACKING[1][0], -1 * ATTACKING[1][1])]
				
		func compile_pseudo_moves(main):
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if typeof(destination_state) == typeof("Out Of Range"):
					continue
				if destination_state == null:
					pseudo_moves.append(main.Move.new(self.piece_position, candidate_destination))
			if self.is_first_move:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + 2 * MOVEMENT[0][0], candidate_destination[1] + 2 * MOVEMENT[0][1])
				var destination_state = main.access_state(candidate_destination)
				if typeof(destination_state) == typeof("Out Of Range"):
					pass
				elif destination_state == null:
					pseudo_moves.append(main.Move.Pawn_Jump.new(self.piece_position, candidate_destination))
			for direction in ATTACKING:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if typeof(destination_state) == typeof("Out Of Range"):
					continue
				if destination_state != null:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append(main.Move.Capture.new(self.piece_position, candidate_destination, candidate_destination))
				if main.en_passant != null:
					if Vector2(main.en_passant[0], main.en_passant[1] + HEADING) == candidate_destination:
						var en_passant_destination = Vector2(main.en_passant[0], main.en_passant[1] + HEADING)
						if self.piece_alliance != main.access_state(main.en_passant).piece_alliance:
							print(" --- EN PASSANT --- ")
							pseudo_moves.append(main.Move.En_Passant.new(self.piece_position, en_passant_destination, main.en_passant))
							
			return pseudo_moves
