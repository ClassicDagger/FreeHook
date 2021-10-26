extends Sprite

const PARTICLE = preload("res://Scenes/Particle.tscn")

onready var characterSprite = $Character
onready var characterTween = $CharacterTween
onready var logoSprite = $Logo
onready var logoTween = $LogoTween
onready var starSpawnPos = $StarSpawns
onready var starSpawnTimer = $StarSpawnTimer

var starsCreated = 0

func _ready():
	Global.soundControl.Play("Intro")
	$Logo.playing = true
	AnimateCharacterDown()

func AnimateCharacterDown():
	characterTween.interpolate_property(characterSprite, "position", characterSprite.position, characterSprite.position + Vector2(0, 3), .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	characterTween.start()
	yield(characterTween, 'tween_completed')
	AnimateCharacterUp()

func AnimateCharacterUp():
	characterTween.interpolate_property(characterSprite, "position", characterSprite.position, characterSprite.position + Vector2(0, -3), .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	characterTween.start()
	yield(characterTween, 'tween_completed')
	AnimateCharacterDown()

func AnimateLogoDown():
	logoTween.interpolate_property(logoSprite, "position", logoSprite.position, logoSprite.position + Vector2(0, 3), .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	logoTween.start()
	yield(logoTween, 'tween_completed')
	AnimateLogoUp()

func AnimateLogoUp():
	logoTween.interpolate_property(logoSprite, "position", logoSprite.position, logoSprite.position + Vector2(0, -3), .8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	logoTween.start()
	yield(logoTween, 'tween_completed')
	AnimateLogoDown()

func PressedNew():
	var resetBirdList = {
	"Cells" : false,
	"Caves" : false,
	"Dunes" : false,
	"Fortress" : false,
	"Palms" : false,
	}
	Global.soundControl.Play("UIClick")
	Global.playerData = null
	Global.birdList = resetBirdList
	Global.runTime = 0
	Global.gemsCollected.clear()
	
	get_tree().change_scene("res://Scenes/World.tscn")

func PressedContinue():
	Global.soundControl.Play("UIClick")
	get_tree().change_scene("res://Scenes/World.tscn")
	Global.LoadData()

func PressedExit():
	get_tree().quit()
	Global.soundControl.Play("UIClick")

func HoverButton():
	Global.soundControl.Play("UIHover")

func SpawnStars():
	var newStar = PARTICLE.instance()
	newStar.UpdateParticle("Stars")
	add_child(newStar)
	newStar.position = starSpawnPos.position + Vector2(Global.rng.randi_range(-55, 55), Global.rng.randi_range(-10, 10))

func FinishedAnimation():
	AnimateLogoDown()
	
	while starsCreated <= 13:
		starsCreated += 1
		starSpawnTimer.wait_time = 0.15
		starSpawnTimer.start()
		SpawnStars()
		yield(starSpawnTimer, 'timeout')
	starSpawnTimer.stop()
	
#	while iteration < 8:
#		SpawnStars()
#		starSpawnTimer.wait_time = 0.1
#		starSpawnTimer.start()
#		iteration += 1
#		yield(starSpawnTimer, 'timeout')
