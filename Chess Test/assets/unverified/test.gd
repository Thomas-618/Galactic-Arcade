extends Node

onready var main = $".."

func minimax(alliance, alpha, beta, depth):
	if depth == 0: # TODO: Implement Game Over Condition
		return evaluate_board()
	var selected_move
	if alliance == main.Piece.Alliance.WHITE:
		var maximum = -INF
		for move in main.compile_all_legal_moves(main.Piece.Alliance.BLACK):
			move.apply_move()
			var value = minimax(main.Piece.Alliance.BLACK, alpha, beta, depth - 1)
			move.unapply_move()
			alpha = max(alpha, value)
			if beta <= alpha:
				break
		return maximum
	elif alliance == main.Piece.Alliance.BLACK:
		var minimum = INF
		for move in main.compile_all_legal_moves(main.Piece.Alliance.WHITE):
			move.apply_move()
			var value = minimax(main.Piece.Alliance.WHITE, alpha, beta, depth - 1)
			move.unapply_move()
			beta = min(beta, value)
			if beta <= alpha:
				break
		return minimum

func minimax(alliance):
	var start_time = OS.get_unix_time()
	var best_move
	var maximum = -INF
	var minimum = INF
	var current_value
	for move in main.util.get_legal_moves(alliance):
		move.apply_move()
		#main.util.debug_print()
		#print("MOVE MINIMAX : ", move.move_origin, move.move_destination)
		if alliance == main.Piece.Alliance.WHITE:
			current_value = minimize(3)
		elif alliance == main.Piece.Alliance.BLACK:
			current_value = maximize(3)
		move.unapply_move()
		#print("MOVE MINIMA2X : ", move.move_origin, move.move_destination)	
		#main.util.debug_print()
		if alliance == main.Piece.Alliance.WHITE and current_value >= maximum:
			maximum = current_value
			best_move = move
		elif alliance == main.Piece.Alliance.BLACK and current_value <= minimum:
			minimum = current_value
			best_move = move
	var end_time = OS.get_unix_time()
	print("Time Taken: " + String(end_time - start_time))
	best_move.execute_move()

func maximize(depth):
	if depth == 0: # TODO add a game over condition
		return evaluate_board()
	var maximum = -INF
	for move in main.compile_all_legal_moves(main.alliance_turn):
		move.apply_move()
		#print("MOVE_ INFO : ", move.move_origin, move.move_destination)
		#main.util.debug_print()
		var current_value = minimize(depth - 1)
		move.unapply_move()
		#print("MOVE_ UNAPPLY : ", move.move_origin, move.move_destination)
		#main.util.debug_print()
		if current_value >= maximum:
			maximum = current_value
	return maximum

func minimize(depth):
	if depth == 0: # TODO add a game over condition
		return evaluate_board()
	var minimum = -INF
	for move in main.compile_all_legal_moves(main.alliance_turn):
		move.apply_move()
		#print("MOVE_ INFO : ", move.move_origin, move.move_destination)	
		#main.util.debug_print()
		var current_value = maximize(depth - 1)
		move.unapply_move()
		#print("MOVE_ UNAPPLY : ", move.move_origin, move.move_destination)
		#main.util.debug_print()
		if current_value >= minimum:
			minimum = current_value
	return minimum

func evaluate_board():
	var white_score = calculate_piece_bonus(main.Piece.Alliance.WHITE)
	var black_score = calculate_piece_bonus(main.Piece.Alliance.BLACK)
	return white_score - black_score

func calculate_piece_bonus(alliance):
	var bonus = 0
	for piece in main.active_pieces:
		if piece.piece_alliance == main.alliance_turn:
			bonus += piece.VALUE
	return bonus

func calculate_mobility_bonus():
	var bonus = 0
	pass
	


