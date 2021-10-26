extends AnimatedSprite

const PARTICLE = preload("res://Scenes/Particle.tscn")

func PlayerEnter(body):
	Global.gemsCollected.append(position)
	Global.soundControl.Play("GemGet")
	var newStars = PARTICLE.instance()
	newStars.UpdateParticle("Stars")
	newStars.position = position
	get_parent().add_child(newStars)
	
	queue_free()
