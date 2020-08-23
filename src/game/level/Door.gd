extends AnimatedSprite


var state = "closed"


func _ready():
	pass
	
func point_in_door(point: Vector2):
	if point == position + Vector2(-8, -8):
		return true
	if point == position + Vector2(8, 8):
		return true
	if point == position + Vector2(-8, 8):
		return true
	if point == position + Vector2(8, -8):
		return true
	return false

func close():
	if state == "open":
		state = "closed"
		play("close")

func open():
	if state == "closed":
		state = "open"
		play("open")
