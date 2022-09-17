extends Node

enum Alliance {WHITE, BLACK}

func is_white(alliance):
	if alliance == Alliance.WHITE:
		return true
	return false

func is_black(alliance):
	if alliance == Alliance.BLACK:
		return true
	return false

func get_opponent(alliance):
	match alliance:
		Alliance.WHITE:
			return Alliance.BLACK
		Alliance.BLACK:
			return Alliance.WHITE

func get_direction(alliance):
	pass
