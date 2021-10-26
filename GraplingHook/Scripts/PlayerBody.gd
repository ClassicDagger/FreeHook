extends KinematicBody2D

const PARTICLE = preload("res://Scenes/Particle.tscn")

onready var animator = $PlayerSprite
onready var fadeEffect1 = $PlayerSprite/FadeEffect1
onready var fadeEffect2 = $PlayerSprite/FadeEffect2
onready var playerTween = $PlayerTween
onready var graplingHook = $GraplingHook
onready var stepTimer = $StepTimer

var grounded = false
var moveSpeed = 1
var savedDirection = 0
const acceleration = 6
const maxMovespeed = 72
const maxSpeed = 300
const jumpForce = 250
const gravity = 10
const chainPull = 225

var hookCharge = 0
var hookStage = 0
var maxCharge = 30

var velocity = Vector2.ZERO
var recovering = false
var canHook = true
var animationFlag = true
var fallFlag = false
var fallingLong = false
var hitPin = false
var chargingHangHook = false
var shockwave = false
var savedPin = []
var reachedDestination = false

var stunned = false

var updatingCamera = false

var spectralPosition = Vector2.ZERO
var spectralDirection = 0

func _ready():
	Global.player = self
	if Global.playerData != null:
		position = Global.playerData.playerPosition

func _physics_process(delta):
	#Walking
	var direction = 0
	if !stunned and !shockwave and hookCharge < 50:
		direction = sign(Input.get_action_strength('Right') - Input.get_action_strength('Left'))
	spectralDirection = direction
	
	if savedDirection != direction:
		animationFlag = true
		moveSpeed = 1
		savedDirection = direction
	
	if direction > 0:
		if grounded:
			if hookCharge > 1:
				if moveSpeed > 8:
					if animator.animation != "ChargeWalk":
						Global.soundControl.Play("ChargeGraple", 1)
						animator.animation = "ChargeWalk"
				if hookCharge > 25:
					moveSpeed *= .95
			else:
				moveSpeed += acceleration
				animator.animation = "Walk"
			animator.flip_h = false
			fallingLong = false
		if moveSpeed > maxMovespeed:
			moveSpeed = maxMovespeed
		if animationFlag:
			animator.frame = 6
			animationFlag = false
			if stepTimer.is_stopped():
				stepTimer.start(0.4)
	elif direction < 0:
		if grounded:
			animator.flip_h = true
			if hookCharge > 1:
				if moveSpeed > 8:
					if animator.animation != "ChargeWalk":
						Global.soundControl.Play("ChargeGraple", 1)
						animator.animation = "ChargeWalk"
				if hookCharge > 25:
					moveSpeed *= .95
			else:
				moveSpeed += acceleration
				animator.animation = "Walk"
			fallingLong = false
		if moveSpeed > maxMovespeed:
			moveSpeed = maxMovespeed
		if animationFlag:
			animator.frame = 6
			animationFlag = false
			if stepTimer.is_stopped():
				stepTimer.start(0.4)
			fadeEffect1.frame = 6
			fadeEffect2.frame = 6
			playerTween.interpolate_property(fadeEffect1, "position", fadeEffect1.position, Vector2(2, 0), .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			playerTween.start()
			playerTween.interpolate_property(fadeEffect2, "position", fadeEffect2.position, Vector2(4, 0), .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			playerTween.start()
	else:
		stepTimer.stop()
		if shockwave:
			animator.animation = "Shockwave"
		elif hookCharge == 0 and grounded and !fallingLong and animator.animation != "Fell":
			animator.animation = "Idle"
		
			
		if animationFlag:
			animationFlag = false
			playerTween.interpolate_property(fadeEffect1, "position", fadeEffect1.position, Vector2.ZERO, .1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			playerTween.start()
			playerTween.interpolate_property(fadeEffect2, "position", fadeEffect2.position, Vector2.ZERO, .2, Tween.TRANS_LINEAR, Tween.EASE_IN)
			playerTween.start()
	
	#Hook physics
	var hookedPos = Vector2.ZERO
	if graplingHook.hooked:
		stepTimer.stop()
		if !chargingHangHook:
			animator.animation = "Hold"
		
		if !reachedDestination:
			hookedPos = to_local(graplingHook.tip).normalized()
			velocity.y = 0
		var xdifference = abs(to_local(position).x - to_local(graplingHook.tip).x)
		var ydifference = abs(to_local(position).y - to_local(graplingHook.tip).y)
		
		if hitPin:
			if xdifference <= 5:
				hookedPos.x = 0
			if ydifference <= 7:
				hookedPos.y = 0
			if hookedPos == Vector2.ZERO:
				reachedDestination = true
		else:
			if xdifference <= 10 and ydifference <= 10:
				graplingHook.Reset()
		
		var collisionInfo
		if !chargingHangHook and hookedPos != null:
			collisionInfo = move_and_collide(hookedPos * chainPull * delta)
		
		if collisionInfo != null:
			graplingHook.Reset()
			Global.soundControl.Play("HitWall")
			
		
	else:
		velocity.y += gravity
		velocity.x += direction * moveSpeed
		move_and_slide(velocity, Vector2.UP)
		velocity.x -= direction * moveSpeed
		
		velocity.y = clamp(velocity.y, -maxSpeed * .8, maxSpeed * 1.4)
		velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
		
		grounded = is_on_floor()
		if grounded:
			if fallFlag:
				if updatingCamera:
					UpdateCamera($MainCamera)
				
				var landingPuff = PARTICLE.instance()
				landingPuff.UpdateParticle("LandingPuff")
				get_parent().add_child(landingPuff)
				landingPuff.position = position
				fallFlag = false
				if stepTimer.is_stopped():
					stepTimer.start(0.4)
				
				if fallingLong:
					if animator.animation != "Fell":
						var newBigPuff = PARTICLE.instance()
						newBigPuff.UpdateParticle("Bonk")
						newBigPuff.position = position
						get_parent().add_child(newBigPuff)
						reachedDestination = false
						Global.soundControl.Play("Fell")
						animator.animation = "Fell"
						fallingLong = false
				
			
			
			if recovering:
				canHook = true
				recovering = false
				graplingHook.ResetPins()
			if velocity.y >= 5:
				velocity.y = 5
		elif is_on_ceiling() and velocity.y <= -8:
			velocity.y = -8
		else:
			stepTimer.stop()
			moveSpeed *= 0.96
			if !fallFlag and !graplingHook.hooked:
				animator.animation = "FallTransition"
				fallFlag = true
				#animator.animation = "FallLoop"
		
	
	#	if Input.is_action_pressed('Cheat'):
	#		position = Vector2(113, 253)
	#
	#	if Input.is_action_pressed('CheatHarder'):
	#		position = Vector2(185, -380)
	#
	#	if Input.is_action_pressed('CheatMost'):
	#		position = Vector2(297, -885)
	
	if Input.is_action_pressed('Hook'):
		if !stunned and !shockwave:
			if grounded:
				if canHook:
					hookCharge += 1
					
					var mousePos = get_global_mouse_position()
					if mousePos.x > position.x:
						animator.flip_h = false
					else:
						animator.flip_h = true
					
					if hookCharge >= maxCharge:
						hookCharge = maxCharge
						if animator.animation != "HookMax":
							hookStage = 6
							if moveSpeed <= 8:
								animator.animation = "HookMax"
								Global.soundControl.Play("ChargeGraple", 1.8)
					else:
						if animator.animation != "HookLight":
							hookStage = 2.8
							if moveSpeed <= 8:
								animator.animation = "HookLight"
								Global.soundControl.Play("ChargeGraple", 1)
			if graplingHook.hit == "Pin" and hookedPos == Vector2.ZERO:
				chargingHangHook = true
				hookCharge += 1
				
				var mousePos = get_global_mouse_position()
				if mousePos.x > position.x:
					animator.flip_h = false
				else:
					animator.flip_h = true
				
				if hookCharge >= maxCharge:
					hookCharge = maxCharge
					if animator.animation != "HookHoldMax":
						animator.animation = "HookHoldMax"
						hookStage = 6
						Global.soundControl.Play("ChargeGraple", 1.8)
				else:
					if animator.animation != "HookHoldLight":
						animator.animation = "HookHoldLight"
						hookStage = 2.8
						Global.soundControl.Play("ChargeGraple", 1)
			else:
				pass
	
	if Input.is_action_just_released('Hook'):
		if !stunned and !shockwave:
			if canHook:
				canHook = false
				graplingHook.Shoot(get_local_mouse_position(), hookStage)
				hookCharge = 0
			if graplingHook.hooked:
				if graplingHook.hit == "Pin":
					chargingHangHook = false
					graplingHook.Shoot(get_local_mouse_position(), hookStage)
					hookCharge = 0
				else:
					graplingHook.Reset()
	
	spectralPosition = Vector2.ZERO
	if !reachedDestination:
		if hookedPos == Vector2.ZERO:
			if spectralDirection > 0:
				spectralPosition.x = -2
			elif spectralDirection < 0:
				spectralPosition.x = 2
			else:
				spectralPosition.x = 0
			
			if velocity.y > 5:
				spectralPosition.y = -2
			elif velocity.y < 5:
				spectralPosition.y = 2
			else:
				spectralPosition.y = 0
		else:
			if hookedPos.x > 0:
				spectralPosition.x = -2
			elif hookedPos.x < 0:
				spectralPosition.x = 2
			else:
				spectralPosition.x = 0
			
			if hookedPos.y > 5:
				spectralPosition.y = -2
			elif hookedPos.y < 5:
				spectralPosition.y = 2
			else:
				spectralPosition.y = 0
	
	fadeEffect1.position = spectralPosition
	fadeEffect2.position = spectralPosition * 2
	
	fadeEffect1.frame = animator.frame +1
	fadeEffect2.frame = animator.frame
	
	fadeEffect1.animation = animator.animation
	fadeEffect2.animation = animator.animation
	fadeEffect1.flip_h = animator.flip_h
	fadeEffect2.flip_h = animator.flip_h
	
	

func AnimationFinished():
	if fallFlag and animator.animation != "FallLoop":
		if animator.animation != "Fell":
			animator.animation = "FallLoop"
			fallingLong = true
	if animator.animation == "HookLight" or animator.animation == "HookHoldLight":
		#Global.soundControl.StopSound("ChargeGraple")
		Global.soundControl.Play("ChargeGraple", 1.2)
	if animator.animation == "HookMedium" or animator.animation == "HookHoldMedium":
		#Global.soundControl.StopSound("ChargeGraple")
		Global.soundControl.Play("ChargeGraple", 1.4)
	if animator.animation == "HookMax" or animator.animation == "HookHoldMax":
		#Global.soundControl.StopSound("ChargeGraple")
		Global.soundControl.Play("ChargeGraple", 1.8)

func StepTimerInterval():
	if moveSpeed > 10:
		var newStepParticle = PARTICLE.instance()
		newStepParticle.UpdateParticle("Step")
		get_parent().add_child(newStepParticle)
		newStepParticle.position = position
		newStepParticle.flip_h = animator.flip_h
		var randomInflection = Global.rng.randf_range(1.0, 1.4)
		Global.soundControl.Play("StoneStep", randomInflection)

func UpdateCamera(givenCamera):
	givenCamera.current = true

func DisablePlayerAction():
	stunned = true

func EnablePlayerAction():
	stunned = false
