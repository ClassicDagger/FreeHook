extends Node2D

onready var player = $PlayerBody
onready var optionsWindow = $PlayerBody/OptionsMenu

#cinematics
onready var slowmoTimer =  $SlowmoTimer
onready var cinematicTimer = $Cinematics/CinematicTimer
onready var cinematicBlock = $Cinematics/CinematicBlock

onready var endTween = $CanvasLayer/EndText/EndTextTween
onready var endText = $CanvasLayer/EndText

onready var finalIsland = $Terrain/FinalIsland
onready var finalIslandFree = preload("res://Sprites/Terrain/terrain_EndScene.png")

var movingIsland = false
var islandSpeed = .01

var runStarted = false

func _ready():
	
	if Global.playerData == null:
		OpeningScene()
	else:
		$PlayerBody/MainCamera.current = true
		cinematicBlock.queue_free()
		runStarted = true
		UpdateGems()
		Global.soundControl.TurnMusicOn()

func OpeningScene():
	player.stunned = true
	cinematicTimer.wait_time = 2
	cinematicTimer.start()
	Global.optionsMenu.UpdateBirds()
	
	yield(cinematicTimer, 'timeout')
	runStarted = true
	player.stunned = false
	cinematicBlock.queue_free()
	Global.soundControl.Play("ThrowGraple")
	player.updatingCamera = true
	cinematicTimer.wait_time = 3
	cinematicTimer.start()
	yield(cinematicTimer, 'timeout')
	Global.soundControl.TurnMusicOn()

func EndScene():
	runStarted = false
	player.animator.animation = "Shockwave"
	player.shockwave = true
	endText.percent_visible = 0
	endText.text = "THANK   YOU   FOR   PLAYING!"
	$PlayerBody/MainCamera/Screenshake.Start(3, .10, 3)
	$PlayerBody/MainCamera.limit_top = -10000000
	$PlayerBody/MainCamera.limit_right = 10000000
	$CanvasLayer/OptionsMenu.inCutscene = true
	slowmoTimer.wait_time = .5
	slowmoTimer.start()
	Engine.time_scale = 0.3
	movingIsland = true
	finalIsland.texture = finalIslandFree
	cinematicTimer.wait_time = 5
	cinematicTimer.start()
	yield(cinematicTimer, 'timeout')
	endTween.interpolate_property($CanvasLayer/EndTransition, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	endTween.start()
	yield(endTween, 'tween_completed')
	endTween.interpolate_property(endText, "percent_visible", 0, 1, 4)
	endTween.start()
	yield(endTween, 'tween_completed')
	cinematicTimer.wait_time = 1.75
	cinematicTimer.start()
	yield(cinematicTimer, 'timeout')
	cinematicTimer.wait_time = 1.75
	cinematicTimer.start()
	DisplayFinishedTime(Global.runTime)
	Global.soundControl.Play("Time")
	yield(cinematicTimer, 'timeout')
	$CanvasLayer/TotalGems.text = "$" + str(Global.gemsCollected.size())
	Global.soundControl.Play("GemGet")
	cinematicTimer.wait_time = 1.75
	cinematicTimer.start()
	yield(cinematicTimer, 'timeout')
	$CanvasLayer/TotalBirds.text = DisplayFreeBirds()
	if $CanvasLayer/TotalBirds.text != "":
		Global.soundControl.Play("Tweet")
	cinematicTimer.wait_time = 2.5
	cinematicTimer.start()
	yield(cinematicTimer, 'timeout')
	player.position = Vector2(465, 645)
	Global.SaveData()
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func UpdateGems():
	for coordinate in Global.gemsCollected:
		for gem in $Gems.get_children():
			if gem.position == coordinate:
				gem.queue_free()

func UpdateFreeBirds():
	for bird in $Terrain/FinalIsland/FreeBirds.get_children():
		bird.visible = false
	
	for i in range(Global.birdList.values().size()):
		if Global.birdList.values()[i]:
			$Terrain/FinalIsland/FreeBirds.get_child(i).visible = true
		
	
#
#var birdList = {
#	"Cells" : false,
#	"Caves" : false,
#	"Dunes" : false,
#	"Fortress" : false,
#	"Palms" : false,
#	}

func _process(delta):
	if runStarted:
		if player.position.y < -842 and player.position.x > 275:
			Global.soundControl.UpdateMusicLevel(0)
		else:
			if player.position.y < -518:
				Global.soundControl.UpdateMusicLevel(4)
			elif player.position.y < 103:
				Global.soundControl.UpdateMusicLevel(3)
			elif player.position.y < 420:
				Global.soundControl.UpdateMusicLevel(2)
			elif player.position.x < 246 or player.position.y < 548:
				Global.soundControl.UpdateMusicLevel(1)
			else:
				Global.soundControl.UpdateMusicLevel(0)
	
#	if player.position.x > 246 and player.position.y > 547:
#		Global.soundControl.UpdateMusicLevel(0)
	
	
	
	if runStarted:
		Global.runTime += delta
	
	if movingIsland:
		islandSpeed += 0.01
		if islandSpeed > .5:
			islandSpeed = .5
		var projection = Vector2(islandSpeed, -islandSpeed / 2)
		finalIsland.position += projection
		player.position += projection
	
	if player.position.y <= -400:
		var alphaFormula = float(abs(player.position.y) /380 ) -1
		if alphaFormula > 1:
			alphaFormula = 1
		$ParallaxBackground/BrightBackground.modulate = Color(1, 1, 1, alphaFormula)
		$ParallaxBackground/SunLayer.modulate = Color(1, 1, 1, alphaFormula)
	else:
		$ParallaxBackground/BrightBackground.modulate = Color(1, 1, 1, 0)
		$ParallaxBackground/SunLayer.modulate = Color(1, 1, 1, 0)
		$ParallaxBackground/Background.modulate = Color(1, 1, 1, 1)
		$ParallaxBackground/MoonLayer.modulate = Color(1, 1, 1, 1)

func DisplayFinishedTime(givenTime):
	var secs = fmod(Global.runTime, 60)
	var mins = fmod(Global.runTime, 60 * 60) /60
	var hours = fmod(fmod(Global.runTime, 3600 * 60) / 3600, 24)
	
	var printTime = "%02d : %02d : %02d" % [hours, mins, secs]
	
	$CanvasLayer/TimeSpent.text = printTime

func DisplayFreeBirds():
	var birdText = ""
	for birdFreed in Global.birdList.values():
		if birdFreed:
			birdText += "#"
	return birdText

func SlowmoTimeout():
	Engine.time_scale = 1

func PlayerEnteredBirdArea(body):
	var maxDelay = 8
	for birdFreed in Global.birdList.values():
		if birdFreed:
			maxDelay -= 1.5
	
	if maxDelay != 8:
		$BirdAreaTimer.wait_time = maxDelay
		$BirdAreaTimer.start()

func PlayerExitedBirdArea(body):
	$BirdAreaTimer.stop()

func Tweet():
	Global.soundControl.Play("Tweet")
