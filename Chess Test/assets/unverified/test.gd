class Square:
	
	var squareCoordinate: int
	
	func _init(squareCoordinate: int = 0):
		self.squareCoordinate = squareCoordinate
	
	func isSquareOccupied():
		pass
	
	func getPiece():
		pass
		
	class EmptySquare extends Square:
		
		func _init(squareCoordinate: int = 0):
			._init(squareCoordinate)
		
		func isSquareOccupied() -> bool:
			return false
		
		func getPiece() -> Piece:
			return null
