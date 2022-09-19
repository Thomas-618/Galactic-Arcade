extends Node

onready var main = $".."
var counter = 0
func minimax(alliance):
	var start_time = OS.get_unix_time()
	var selected_move
	
	var alpha = -INF
	var beta = INF
	
	var maximum = -INF
	var minimum = INF
	
	for move in main.util.get_legal_moves(alliance):
		move.apply_move()
		counter += 1
		if alliance == main.Piece.Alliance.WHITE:
			var value = minimize(alpha, beta, 3)
			if value > maximum:
				maximum = value
				selected_move = move
			alpha = max(alpha, value)
			if beta < alpha:
				break
		elif alliance == main.Piece.Alliance.BLACK:
			var value = maximize(alpha, beta, 3)
			if value < minimum:
				minimum = value
				selected_move = move
			beta = min(beta, value)
			if beta <= alpha:
				break
		move.unapply_move()
	selected_move.execute_move()
	print(counter)
	var end_time = OS.get_unix_time()
	print("Time Taken: " + String(end_time - start_time))

func maximize(alpha, beta, depth):
	if depth == 0: # TODO add a game over condition
		return evaluate_board()
	var maximum = -INF
	for move in main.compile_all_legal_moves(main.Piece.Alliance.BLACK):
		move.apply_move()
		counter += 1
		var value = minimize(alpha, beta, depth - 1)
		move.unapply_move()
		maximum = max(maximum, value)
		alpha = max(alpha, value)
		if beta <= alpha:
			break
	return maximum

func minimize(alpha, beta, depth):
	if depth == 0: # TODO add a game over condition
		return evaluate_board()
	var minimum = INF
	for move in main.compile_all_legal_moves(main.Piece.Alliance.WHITE):
		move.apply_move()
		counter += 1
		var value = maximize(alpha, beta, depth - 1)
		move.unapply_move()
		minimum = min(minimum, value)
		beta = min(beta, value)
		if beta <= alpha:
			break
	return minimum

func evaluate_board():
	var white_score = calculate_piece_bonus(main.Piece.Alliance.WHITE)
	var black_score = calculate_piece_bonus(main.Piece.Alliance.BLACK)
	return white_score - black_score

func calculate_piece_bonus(alliance):
	var bonus = 0
	for piece in main.active_pieces:
		if piece.piece_alliance == alliance:
			bonus += piece.VALUE + piece.return_location_bonus()
	return bonus

func calculate_mobility_bonus():
	var bonus = 0
	pass
	


