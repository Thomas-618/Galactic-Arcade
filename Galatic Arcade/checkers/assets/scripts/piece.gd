# Stores all game logic for piece behavior.
extends Node
# Blueprint for a checker piece's behavior.
class Piece:
	# Script Reference!
	var main #: Node
	# Data Types!
	enum Alliance {BLACK, RED}
	enum Type {KING, PAWN}
	# Member Variables!
	var piece_gui #: Sprite
	var piece_alliance #: Alliance
	var piece_type #: Type
	var piece_position #: Vector2
	# ----- ----- ----- ----- -----
	
	# Initializes an instance of the piece class.
	func _init(main = null, piece_gui = null, 
			   piece_alliance = null, piece_type = null, piece_position = null):
		self.main = main
		self.piece_gui = piece_gui
		self.piece_alliance = piece_alliance
		self.piece_type = piece_type
		self.piece_position = piece_position
	
	# Abstract function for sub-classes to override.
	func compile_moves() -> Array:
		return []
	# ----- ----- ----- ----- -----
	
	# Blueprint for a king checker piece's behavior.
	class King extends Piece:                                                                                                
		const MOVEMENT := [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]
		
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null):
			._init(main, piece_gui, piece_alliance, Type.KING, piece_position)
		
		# Utilizes the MOVEMENT constants to return a list of pseudo-legal moves.
		func compile_moves() -> Array:
			var captures = []
			var moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				var candidate_path = Vector2(candidate_destination[0] + direction[0], 
											 candidate_destination[1] + (direction[1]))
				candidate_destination = Vector2(candidate_destination[0] + (2 * direction[0]), 
												candidate_destination[1] + (2 * direction[1]))
				var path_state = main.access_state(candidate_path)
				if (path_state is Piece and path_state.piece_alliance != self.piece_alliance and 
						main.access_state(candidate_destination) == null):
					captures.append(main.Move.Capture.new(main, self, path_state,
														  self.piece_position, candidate_destination))
				if captures.size() > 0:
					return [captures, moves]
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + direction[1])
				var destination_state = main.access_state(candidate_destination)
				if destination_state == null:
						moves.append(main.Move.new(main, self, self.piece_position, 
											candidate_destination))
			return [captures, moves]
	# ----- ----- ----- ----- -----
	
	# Blueprint for a pawn checker piece's behavior.
	class Pawn extends Piece:                                                                                                      
		const MOVEMENT := [Vector2(-1, 1), Vector2(1, 1)]
		var HEADING 
		
		func _init(main = null, piece_gui = null, 
				   piece_alliance = null, piece_position = null):
			._init(main, piece_gui, piece_alliance, Type.PAWN, piece_position)
			if self.piece_alliance == Alliance.BLACK:
				self.HEADING = 1
			elif self.piece_alliance == Alliance.RED:
				self.HEADING = -1
		
		# Utilizes the MOVEMENT constants to return a list of pseudo-legal moves.
		func compile_moves() -> Array:
			var captures = []
			var moves = []
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				var candidate_path = Vector2(candidate_destination[0] + direction[0], 
											 candidate_destination[1] + (HEADING * direction[1]))
				candidate_destination = Vector2(candidate_destination[0] + (2 * direction[0]), 
											candidate_destination[1] + (2 * HEADING * direction[1]))
				var path_state = main.access_state(candidate_path)
				if (path_state is Piece and path_state.piece_alliance != self.piece_alliance and 
						main.access_state(candidate_destination) == null):
					captures.append_array(check_pawn_promotion(
										  main.Move.Promotion.Move_Type.CAPTURE_MOVE, path_state,
										  candidate_destination))
				if captures.size() > 0:
					return [captures, moves]
			for direction in MOVEMENT:
				var candidate_destination = self.piece_position
				candidate_destination = Vector2(candidate_destination[0] + direction[0], 
												candidate_destination[1] + (HEADING * direction[1]))
				var destination_state = main.access_state(candidate_destination)
				if destination_state == null:
						moves.append_array(check_pawn_promotion(
										   main.Move.Promotion.Move_Type.BASE_MOVE, null,
										   candidate_destination))
			return [captures, moves]
		
		# Helper function to compile_pseudo_moves(), which returns special-case promotion moves.
		func check_pawn_promotion(move_type, path_state, candidate_destination) -> Array:
			var discovered_moves = []
			if self.piece_alliance == Alliance.BLACK:
				if candidate_destination[1] != main.util.RED_STARTING_RANK:
					if move_type == main.Move.Promotion.Move_Type.BASE_MOVE:
						discovered_moves.append(main.Move.new(main, self, self.piece_position, 
															  candidate_destination))
					elif move_type == main.Move.Promotion.Move_Type.CAPTURE_MOVE:
						discovered_moves.append(main.Move.Capture.new(main, self, path_state,
												self.piece_position, candidate_destination))
					return discovered_moves
			elif self.piece_alliance == Alliance.RED:
				if candidate_destination[1] != main.util.BLACK_STARTING_RANK:
					if move_type == main.Move.Promotion.Move_Type.BASE_MOVE:
						discovered_moves.append(main.Move.new(main, self, self.piece_position, 
															  candidate_destination))
					elif move_type == main.Move.Promotion.Move_Type.CAPTURE_MOVE:
						discovered_moves.append(main.Move.Capture.new(main, self, path_state,
												self.piece_position, candidate_destination))
					return discovered_moves
			discovered_moves.append(main.Move.Promotion.new(main, self, move_type, path_state,
									self.piece_position, candidate_destination))
			return discovered_moves
	# ----- ----- ----- ----- -----
