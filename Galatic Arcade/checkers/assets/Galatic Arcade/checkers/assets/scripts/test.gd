# Stores test case, for debugging purposes.
extends Node
# Class References!
onready var main := $"../Main"
# ----- ----- ----- ----- -----

# Sets the main.board_state to a test case, checking for legal moves if in check.
func set_promotion_test_board_state():
	main.alliance_turn = main.Piece.Alliance.RED # next_turn() is called to start with the white.
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.KING, Vector2(4, 8))
	main.create_piece(main.Piece.Alliance.BLACK, main.Piece.Type.PAWN, Vector2(7, 7))
	
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.KING, Vector2(5, 1))
	main.create_piece(main.Piece.Alliance.RED, main.Piece.Type.PAWN, Vector2(8, 2))
	main.update_active_pieces()
	main.next_turn()
# ----- ----- ----- ----- -----
