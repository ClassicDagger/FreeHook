extends Camera2D

onready var cameraTween = $CameraTween
var lastPos = Vector2.ZERO

func _process(delta):
	var playerPos = get_node("../PlayerBody").global_position
	var x = floor(playerPos.x / 256) * 256
	var y = floor(playerPos.y / 144) * 144
	
	if lastPos != Vector2(x, y):
		lastPos = Vector2(x, y)
		cameraTween.interpolate_property(self, "global_position", global_position, Vector2(x, y), .3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		cameraTween.start()

