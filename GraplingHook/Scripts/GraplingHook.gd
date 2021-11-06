extends Node2D

const PARTICLE = preload("res://Scenes/Particle.tscn")

onready var chains = $Chain
onready var hookTween = $HookTween
onready var noiseDelay = $NoiseDelay
const gravity = 2.2
var speed = 2

var direction = Vector2.ZERO
var tip = Vector2.ZERO

var flying = false
var hooked = false
var chainLife = 1.5
var hookLife = 2
var hookAvailable = true
var returning = false

var hit = ""

var pinLocked = false

var savedPins = []

func Shoot(givenDirection, givenStage):
	if givenStage == 0:
		givenStage = 2
	Global.soundControl.Play("ThrowGraple", 0.5)
	hookAvailable = false
	direction = givenDirection.normalized()
	flying = true
	tip = self.global_position
	
	speed = givenStage

func Reset():
	if !pinLocked:
		print("resetting    !!")
		hit = ""
		flying = false
		hooked = false
		speed = 2
		hookLife = 250
		chainLife = 75
		noiseDelay.stop()
		#get_parent().movingToLocation = false
		get_parent().reachedDestination = false
		get_parent().hitPin = false
		get_parent().recovering = true

func _process(delta):
	if flying:
		var xdifference = abs(get_parent().position.x - tip.x)
		if xdifference > 125:
			Reset()
		
		
		if tip.y >= (get_parent().position.y + 65):
			flying = false
			hooked = false
			get_parent().recovering = true
			#get_parent().reachedDestination = false
			#SoftReset()
		if tip.y <= (get_parent().position.y - 275):
			flying = false
			hooked = false
			get_parent().recovering = true
			#get_parent().reachedDestination = false
		
#		var ydifference = abs(get_parent().position.y - tip.y)
#		print(ydifference)
#		if ydifference > 75:
#			Reset()
		
		#if xdif
	
	self.visible = flying or hooked
	if visible:
		var tipLocal = to_local(tip)
		$Tip.rotation = self.position.angle_to_point(tipLocal) - deg2rad(90)
		chains.rotation = self.position.angle_to_point(tipLocal) - deg2rad(90)
		chains.position = tipLocal
		chains.region_rect.size.y = tipLocal.length()
		if hooked and hit != "Pin":
			hookLife -= 1 * delta
			if hookLife <= 0:
				Reset()
		elif flying:
			chainLife -= 1 * delta
			if chainLife <= 0:
				Reset()
#		if get_parent().hitPin:

func _physics_process(delta):
	$Tip.global_position = tip
	if flying:
		if !returning:
			direction.y += gravity * delta
			
			if noiseDelay.is_stopped():
				noiseDelay.wait_time = 0.1
				noiseDelay.start()
			var collisionInfo = $Tip.move_and_collide(direction * speed)
			if collisionInfo != null:
				get_parent().movingToLocation = true
				noiseDelay.stop()
				var hookHitParticle = PARTICLE.instance()
				hookHitParticle.UpdateParticle("HookParticle")
				get_parent().get_parent().add_child(hookHitParticle)
				hookHitParticle.position = $Tip.global_position
				Global.soundControl.StopSound("ThrowGraple")
				Global.soundControl.Play("GrapleHit")
				
				var LeaveSmoke = PARTICLE.instance()
				LeaveSmoke.UpdateParticle("CirclePuff")
				get_parent().get_parent().add_child(LeaveSmoke)
				LeaveSmoke.position = get_parent().position
				LeaveSmoke.rotation = $Tip.rotation
				
				hooked = true
				flying = false
				get_parent().reachedDestination = false
				if collisionInfo.get_collider().name == "PinHitbox":
					hit = "Pin"
					pinLocked = true
					chainLife = 75
					var pinHit = collisionInfo.get_collider()
					pinHit.get_child(0).disabled = true
					pinHit.set_collision_layer_bit(3, false)
					savedPins.append(pinHit)
					
					get_parent().hitPin = true
				else:
					hit = "Terrain"
					pinLocked = false
					get_parent().hitPin = false
					if collisionInfo.get_collider().name == "BirdcageHitbox":
						collisionInfo.get_collider().get_parent().OpenCage()
				
			
	tip = $Tip.global_position
	

func ResetPins():
	while savedPins.size() > 0:
		savedPins[0].get_child(0).disabled = false
		savedPins[0].set_collision_layer_bit(3, true)
		savedPins.remove(0)

func NoiseStep():
	pass
	#Global.soundControl.Play("HookTravel")
