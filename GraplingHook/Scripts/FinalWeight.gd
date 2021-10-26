extends AnimatedSprite

const PARTICLE = preload("res://Scenes/Particle.tscn")

var damage = 0

var chainAnimation = ["Default", "Scratched", "Worn", "Busted"]

func _ready():
	animation = "Default"

func HitChain(body):
	body.get_parent().Reset()
	damage += 1
	
	var hookHitParticle = PARTICLE.instance()
	hookHitParticle.UpdateParticle("HookParticle")
	get_parent().get_parent().add_child(hookHitParticle)
	hookHitParticle.position = body.global_position
	
	Global.soundControl.Play("ChainHurt")
	
	if damage == 4:
		animation = "WeightBreak"
		get_parent().EndScene()
	else:
		animation = chainAnimation[damage]
