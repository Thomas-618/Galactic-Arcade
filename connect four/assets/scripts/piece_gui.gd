# Stores the GUI representation of a chess piece
extends Sprite
# Class Referenes!
var main
# Member Variables!
var active
var piece
# ----- ----- ----- ----- -----

# Initializes the GUI by passing in parameters for memember variables.
func init(main_reference, piece_reference):
	main = main_reference
	piece = piece_reference
	texture = main.util.compute_sprite_address(piece)
	global_position = translate_position(piece.piece_position)
# ----- ----- ----- ----- -----

# Enlarges GUI of pieces with legal moves.
func feedback_indicator(state):
	if state:
		texture = main.util.compute_sprite_address(piece, true)
	else:
		texture = main.util.compute_sprite_address(piece, false)
# ----- ----- ----- ----- -----

# Translates a position within the main.board_state into coordinates on the screen.
func translate_position(position) -> Vector2:
	return Vector2((73 * position[0]) - 36.5, 550 - (85 * position[1]))
# ----- ----- ----- ----- -----
