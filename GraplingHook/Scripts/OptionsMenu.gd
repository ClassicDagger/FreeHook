extends Control

onready var world = get_node("../../")
onready var birdIcons = $UnlockedBirds
var inCutscene = false

func _ready():
	Global.optionsMenu = self
	UpdateBirds()

func _input(event):
	if event.is_action_pressed('Options'):
		if !inCutscene:
			visible = !visible
			UpdatePlaytime()
			UpdateGems()
			get_tree().paused = !get_tree().paused
		else:
			print("in cutscene!")

func UpdatePlaytime():
	var secs = fmod(Global.runTime, 60)
	var mins = fmod(Global.runTime, 60 * 60) /60
	var hours = fmod(fmod(Global.runTime, 3600 * 60) / 3600, 24)
	
	var printTime = "%02d : %02d : %02d" % [hours, mins, secs]
	$Time.text = printTime

func HoverButton():
	if visible:
		Global.soundControl.Play("UIHover")

func MusicToggle(button_pressed):
	Global.musicOn = !Global.musicOn
	Global.soundControl.UpdateMusicLevel(0)
	Global.soundControl.Play("UIClick")

func SoundToggle(button_pressed):
	Global.soundOn = !Global.soundOn
	Global.soundControl.Play("UIClick")

func ExitPressed():
	Global.soundControl.Play("UIClick")
	visible = false
	get_tree().paused = !get_tree().paused

func PressedMainMenu():
	Global.SaveData()
	get_tree().paused = !get_tree().paused
	get_tree().change_scene("res://Scenes/MainMenu.tscn")

func UpdateBirds():
	for icon in birdIcons.get_children():
		icon.visible = false
	
	for i in range(Global.birdList.values().size()):
		if Global.birdList.values()[i]:
			birdIcons.get_child(i).visible = true
	
	if world != null:
		world.UpdateFreeBirds()

func UpdateGems():
	$Gems.text = "$" + str(Global.gemsCollected.size())
