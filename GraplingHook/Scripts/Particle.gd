extends AnimatedSprite

func UpdateParticle(givenParticle):
	animation = givenParticle
	frame = 0
	if givenParticle == "Bird":
		if global_position.x > 144:
			flip_h = true

func FinishedAnimation():
	if animation != "Bird":
		queue_free()
