extends ParallaxLayer

const CLOUD_SPEED = -8

func _process(delta):
	self.motion_offset.x += CLOUD_SPEED * delta
