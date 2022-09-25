# Stores all game logic for piece behavior.
extends Node
# Blueprint for a chess piece's behavior.
class Piece:
	# Script Reference!
	var main #: Node
	# Data Types!
	enum Alliance {WHITE, BLACK}
	enum Type {KING, QUEEN, ROOK, BISHOP, KNIGHT, PAWN}
	# Member Variables!
	var piece_gui #: Sprite
	var piece_alliance #: Alliance
	var piece_type #: Type
	var piece_position #: Vector2
	var piece_moved #: bool
	# ----- ----- ----- ----- -----
	
	# Initializes an instance of the piece class.
	func _init(main = null, piece_gui = null, 
			   piece_alliance = null, piece_type = null, 
			   piece_position = null, piece_moved = false):
		self.main = main
		self.piece_gui = piece_gui
		self.piece_alliance = piece_alliance
		self.piece_type = piece_type
		self.piece_position = piece_position
		self.piece_moved = piece_moved
	
	# Abstract function for sub-classes to override.
	func compile_pseudo_moves() -> Array:
		return []
	# ----- ----- ----- ----- -----
	
	# Blueprint for a king chess piece's behavior.
	class King extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), 
						   Vector2(0,  -1),  Vector2(0, 1), 
						   Vector2(1,  -1),  Vector2(1, 0),  Vector2(1, 1)]
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the King class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.KING, piece_position, piece_moved)
		
		# Utilizes the MOVEMENT constant to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if destination_state is Piece:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append(main.Move.Capture.new(main, self, self.piece_position, 
											candidate_destination))
					continue
				elif destination_state == null:
						pseudo_moves.append(main.Move.new(main, self, self.piece_position, 
														  candidate_destination))
				else:
					continue
			pseudo_moves.append_array(check_king_castling())
			return pseudo_moves
		
		# Helper function to compile_pseudo_moves(), which returns special-case castling moves.
		func check_king_castling() -> Array:
			var discovered_moves = []
			var king_side = true
			var queen_side = true
			if self.piece_moved:
				return discovered_moves
			if main.alliance_turn != self.piece_alliance: # Prevents infinite cycle.
				return discovered_moves
			var starting_rank = main.util.get_starting_rank(self.piece_alliance)
			var king_rook_piece = main.access_state(Vector2(
										main.util.DEFAULT_KING_SIDE_ROOK_POSITION, starting_rank))
			if not(king_rook_piece is Piece):
				king_side = false
			elif king_rook_piece.piece_moved:
				king_side = false
			var queen_rook_piece = main.access_state(Vector2(
										main.util.DEFAULT_QUEEN_SIDE_ROOK_POSITION, starting_rank))
			if not(queen_rook_piece is Piece):
				queen_side = false
			elif queen_rook_piece.piece_moved:
				queen_side = false
			if not (king_side or queen_side):
				return discovered_moves
			var opponent_moves = main.compile_all_pseudo_moves(main.util.get_opponent_alliance(
															   self.piece_alliance))
			for position in main.util.KING_SIDE_CASTLING_PATH:
				if main.access_state(Vector2(position, starting_rank)) != null:
					king_side = false
					break
			for position in main.util.QUEEN_SIDE_CASTLING_PATH:
				if main.access_state(Vector2(position, starting_rank)) != null:
					queen_side = false
					break
			if not (king_side or queen_side):
				return discovered_moves
			for move in opponent_moves:
				if (
					king_side and
					move.move_destination[0] in main.util.KING_SIDE_CASTLING_PATH and
					move.move_destination[1] == starting_rank
				):
					king_side = false
				if (
					queen_side and
					move.move_destination[0] in main.util.QUEEN_SIDE_CASTLING_PATH and
					move.move_destination[1] == starting_rank
				):
					queen_side = false
			if king_side:
				discovered_moves.append(main.Move.Castle.new(main, self, king_rook_piece, 
															 main.Move.Castle.Castling.KING_SIDE))
			if queen_side:
				discovered_moves.append(main.Move.Castle.new(main, self, queen_rook_piece, 
															 main.Move.Castle.Castling.QUEEN_SIDE))
			return discovered_moves
	# ----- ----- ----- ----- -----
	
	# Blueprint for a queen chess piece's behavior.
	class Queen extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(-1, -1), Vector2(-1, 0), Vector2(-1, 1), 
						   Vector2(0,  -1),  Vector2(0, 1), 
						   Vector2(1,  -1),  Vector2(1, 0),  Vector2(1, 1)]
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the Queen class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.QUEEN, piece_position, piece_moved)
		
		# Utilizes the MOVEMENT constant to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], 
													candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if destination_state is Piece:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(main, self, 
												self.piece_position, candidate_destination))
						break
					elif destination_state == null:
						pseudo_moves.append(main.Move.new(main, self, self.piece_position, 
														  candidate_destination))
					else:
						break
			return pseudo_moves
	# ----- ----- ----- ----- -----
	
	# Blueprint for a rook chess piece's behavior.
	class Rook extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(-1, 0),
						   Vector2(0, -1),  Vector2(0, 1), 
						   Vector2(1, 0)]
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the Rook class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.ROOK, piece_position, piece_moved)
		
		# Utilizes the MOVEMENT constant to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], 
													candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if destination_state is Piece:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(main, self, 
												self.piece_position, candidate_destination))
						break
					elif destination_state == null:
						pseudo_moves.append(main.Move.new(main, self, self.piece_position, 
														  candidate_destination))
					else:
						break
			return pseudo_moves
	# ----- ----- ----- ----- -----
	
	# Blueprint for a bishop chess piece's behavior.
	class Bishop extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(-1, -1), Vector2(-1, 1), 
						   Vector2(1,  -1),  Vector2(1, 1)]
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the Bishop class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.BISHOP, piece_position, piece_moved)
		
		# Utilizes the MOVEMENT constant to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				for _cycle in range(16):
					candidate_destination = Vector2(candidate_destination[0] + direction[0], 
													candidate_destination[1] + direction[1])
					var destination_state = main.access_state(candidate_destination)
					if destination_state is Piece:
						if self.piece_alliance != destination_state.piece_alliance:
							pseudo_moves.append(main.Move.Capture.new(main, self, 
												self.piece_position, candidate_destination))
						break
					elif destination_state == null:
						pseudo_moves.append(main.Move.new(main, self, self.piece_position, 
														  candidate_destination))
					else:
						break
			return pseudo_moves
	# ----- ----- ----- ----- -----
	
	# Blueprint for a knight chess piece's behavior.
	class Knight extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(-2, -1), Vector2(-2, 1), 
						   Vector2(-1, -2), Vector2(-1, 2), 
						   Vector2(1,  -2),  Vector2(1, 2),
						   Vector2(2,  -1),  Vector2(2, 1)]
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the Knight class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.KNIGHT, piece_position, piece_moved)
		
		# Utilizes the MOVEMENT constant to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if destination_state is Piece:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append(main.Move.Capture.new(main, self, self.piece_position, 
											candidate_destination))
					continue
				elif destination_state == null:
						pseudo_moves.append(main.Move.new(main, self, self.piece_position, 
														  candidate_destination))
				else:
					continue
			return pseudo_moves
	# ----- ----- ----- ----- -----
	
	# Blueprint for a pawn chess piece's behavior.
	class Pawn extends Piece:
		# Member Variables!
		const MOVEMENT := [Vector2(0, 1)]
		const CAPTURE  := [Vector2(-1, 1), Vector2(1, 1)]
		var HEADING #: int
		# ----- ----- ----- ----- -----
		
		# Initializes an instance of the Pawn class, calling the super-class constructor.
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null, piece_moved = false):
			._init(main, piece_gui, piece_alliance, Type.PAWN, piece_position, piece_moved)
			if self.piece_alliance == Alliance.WHITE:
				self.HEADING = 1
			elif self.piece_alliance == Alliance.BLACK:
				self.HEADING = -1
		
		# Utilizes the MOVEMENT + CAPTURE constants to return a list of pseudo-legal moves.
		func compile_pseudo_moves() -> Array:
			var pseudo_moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + (HEADING * direction[1]))
				var destination_state = main.access_state(candidate_destination)
				if destination_state == null:
						pseudo_moves.append_array(check_pawn_promotion(
												  main.Move.Pawn_Promotion.Move_Type.BASE_MOVE, 
												  candidate_destination))
			for direction in CAPTURE:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + (HEADING * direction[1]))
				var destination_state = main.access_state(candidate_destination)
				if destination_state is Piece:
					if self.piece_alliance != destination_state.piece_alliance:
						pseudo_moves.append_array(check_pawn_promotion(
												  main.Move.Pawn_Promotion.Move_Type.CAPTURE_MOVE, 
												  candidate_destination))
			pseudo_moves.append_array(check_pawn_double_jump())
			pseudo_moves.append_array(check_pawn_en_passant())
			return pseudo_moves
		
		# Helper function to compile_pseudo_moves(), which returns special-case promotion moves.
		func check_pawn_promotion(move_type, candidate_destination) -> Array:
			var discovered_moves = []
			if self.piece_alliance == Alliance.WHITE:
				if candidate_destination[1] != main.util.BLACK_STARTING_RANK:
					if move_type == main.Move.Pawn_Promotion.Move_Type.BASE_MOVE:
						discovered_moves.append(main.Move.new(main, self, self.piece_position, 
															  candidate_destination))
					elif move_type == main.Move.Pawn_Promotion.Move_Type.CAPTURE_MOVE:
						discovered_moves.append(main.Move.Capture.new(main, self, 
												self.piece_position, candidate_destination))
					return discovered_moves
			elif self.piece_alliance == Alliance.BLACK:
				if candidate_destination[1] != main.util.WHITE_STARTING_RANK:
					if move_type == main.Move.Pawn_Promotion.Move_Type.BASE_MOVE:
						discovered_moves.append(main.Move.new(main, self, self.piece_position, 
															  candidate_destination))
					elif move_type == main.Move.Pawn_Promotion.Move_Type.CAPTURE_MOVE:
						discovered_moves.append(main.Move.Capture.new(main, self, 
												self.piece_position, candidate_destination))
					return discovered_moves
			discovered_moves.append(main.Move.Pawn_Promotion.new(main, self, move_type, 
									self.piece_position, candidate_destination))
			return discovered_moves
		
		# Helper function to compile_pseudo_moves(), which returns special-case double jump moves.
		func check_pawn_double_jump() -> Array:
			var discovered_moves = []
			if self.piece_moved == false:
				for direction in MOVEMENT:
					var candidate_destination = self.piece_position
					var candidate_path = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + (HEADING * direction[1]))
					candidate_destination = Vector2(candidate_destination[0] + direction[0], 
											candidate_destination[1] + (2 * HEADING * direction[1]))
					if ( main.access_state(candidate_destination) == null and
						 main.access_state(candidate_path) == null
						):
						discovered_moves.append(main.Move.Pawn_Jump.new(main, self, 
												self.piece_position, candidate_destination))
			return discovered_moves
		
		# Helper function to compile_pseudo_moves(), which returns special-case en passant moves.
		func check_pawn_en_passant() -> Array:
			var discovered_moves = []
			if main.en_passant_pawn is Piece:
				for direction in CAPTURE:
					var candidate_destination = self.piece_position
					candidate_destination = Vector2(candidate_destination[0] + direction[0], 
													candidate_destination[1])
					var destination_state = main.access_state(candidate_destination)
					if destination_state is Piece and destination_state == main.en_passant_pawn:
						candidate_destination = Vector2(candidate_destination[0], 
												candidate_destination[1] + (HEADING * direction[1]))
						discovered_moves.append(main.Move.Capture.En_Passant.new(main, self,
												self.piece_position, candidate_destination))
			return discovered_moves
	# ----- ----- ----- ----- -----
