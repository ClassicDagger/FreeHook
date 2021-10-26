extends AnimatedSprite

const PARTICLE = preload("res://Scenes/Particle.tscn")
var opened = false
var hSpeed = .6
var vSpeed = .4

var bird
var location

func _ready():
	match global_position.y:
		645.0:
			location = "Cells"
		359.0:
			location = "Caves"
		-41.0:
			location = "Dunes"
		-213.0:
			location = "Fortress"
		-796.0:
			location = "Palms"
	
	if Global.birdList[location]:
		SpawnOpen()
	

func SpawnOpen():
	opened = true
	animation = "Opened"

func OpenCage():
	if !opened:
		opened = true
		animation = "Opened"
		Global.soundControl.Play("Tweet")
		Global.birdList[location] = true
		bird = PARTICLE.instance()
		add_child(bird)
		bird.UpdateParticle("Bird")
		Global.optionsMenu.UpdateBirds()
	

func _process(delta):
	if opened and bird != null:
		hSpeed *= 1.015
		vSpeed *= 1.033
		if global_position.x < 144:
			bird.position.x += hSpeed
			bird.position.y -= vSpeed / 1.2
		else:
			bird.position.x -= hSpeed
			bird.position.y -= vSpeed / 1.2
		
		if bird.position.x > 300 or bird.position.y < -1200:
			bird.queue_free()
			bird = null
