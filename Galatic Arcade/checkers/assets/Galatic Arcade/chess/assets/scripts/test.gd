# Stores test case, for debugging purposes.
extends Node
# Class References!
onready var main := $"../Main"
# ----- ----- ----- ----- -----

# Sets the main.board_state to a test case, checking for legal moves if in check.
func set_check_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.QUEEN,   Vector2(8,7))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.QUEEN,   Vector2(8,1))
	main.update_active_pieces()
	main.en_passant_pawn = null
	main.next_turn()

# Sets the main.board_state to a test case, checking for legal castle moves.
func set_castle_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(1,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.ROOK,   Vector2(8,1))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(1,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.ROOK,   Vector2(8,8))
	main.update_active_pieces()
	main.en_passant_pawn = null
	main.next_turn()

# Sets the main.board_state to a test case, checking for legal pawn promotion moves.
func set_promotion_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN,   Vector2(8,7))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN,   Vector2(8,2))
	main.update_active_pieces()
	main.en_passant_pawn = null
	main.next_turn()

# Sets the main.board_state to a test case, checking for legal en passant moves.
func set_en_passant_test_board_state():
	main.alliance_turn = main.Piece.Alliance.BLACK # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.KING,   Vector2(5,1))
	main.create_piece(main.Piece.Alliance.WHITE, main.Piece.Type.PAWN,   Vector2(5,2))
	
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING,   Vector2(5,8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN,   Vector2(4,4))
	main.update_active_pieces()
	main.en_passant_pawn = null
	main.next_turn()
# ----- ----- ----- ----- -----
