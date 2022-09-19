extends Node

onready var main := get_parent()
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _input(event):
	return
	if event.is_action_pressed("ui_click"):
		var temp = false
		match main.alliance_turn:
			main.Piece.Alliance.WHITE:
				for move in main.white_legal_moves:
					if move is main.Move.Pawn_Promotion:
						temp = true
						move.execute_move()
						break
				if not temp:
					print(temp)
					var move = main.white_legal_moves[rng.randi_range(0, main.white_legal_moves.size() - 1)]
					print("Move Info - [ (", move.move_piece.piece_type,",", move.move_piece.piece_alliance,") - ", move.move_origin, move.move_destination, "]")
					if move is main.Move.Castle:
						print("CASTLE!!")
					elif move is main.Move.Pawn_Promotion:
						print("PROMOTION!")
					elif move is main.Move.Pawn_Jump:
						print("JUMP!")
					elif move is main.Move.En_Passant:
						print("PASSANT!")
					elif move is main.Move.Capture:
						print("CAPTURE!")
					move.execute_move()
			main.Piece.Alliance.BLACK:
				for move in main.black_legal_moves:
					if move is main.Move.Pawn_Promotion:
						temp = true
						move.execute_move()
						break
				if not temp:
					var move = main.black_legal_moves[rng.randi_range(0, main.black_legal_moves.size() - 1)]
					print("Move Info - [ (", move.move_piece.piece_type,",", move.move_piece.piece_alliance,") - ", move.move_origin, move.move_destination, "]")
					if move is main.Move.Castle:
						print("CASTLE!!")
					elif move is main.Move.Pawn_Promotion:
						print("PROMOTION!")
					elif move is main.Move.Pawn_Jump:
						print("JUMP!")
					elif move is main.Move.En_Passant:
						print("PASSANT!")
					elif move is main.Move.Capture:
						print("CAPTURE!")
					move.execute_move()
		main.util.debug_print()

# Comment on function purpose.
func set_check_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.QUEEN,   Vector2(8,7))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.QUEEN,   Vector2(8,1))
	main.update_active_pieces()
	main.move_record = []
	main.en_passant_pawn = null
	main.next_turn()

# Comment on function purpose.
func set_castle_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(1,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(8,1))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(1,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(8,8))
	main.update_active_pieces()
	main.move_record = []
	main.en_passant_pawn = null
	main.next_turn()

# Comment on function purpose.
func set_promotion_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN,   Vector2(8,7))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN,   Vector2(8,2))
	main.update_active_pieces()
	main.move_record = []
	main.en_passant_pawn = null
	main.next_turn()

# Comment on function purpose.
func set_en_passant_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN,   Vector2(5,2))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN,   Vector2(4,4))
	main.update_active_pieces()
	main.move_record = []
	main.en_passant_pawn = null
	main.next_turn()

