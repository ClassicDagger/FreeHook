extends Node

func _ready():
	Global.soundControl = self

func TurnMusicOn():
	for music in $Music.get_children():
		music.playing = true

func Play(givenSound, givenPitch = 1):
	if Global.soundOn:
		if has_node(givenSound):
			if givenSound == "OldManTalking":
				givenPitch = Global.rng.randf_range(0.8, 1.2)
			get_node(givenSound).pitch_scale = givenPitch
			get_node(givenSound).play()

func StopSound(givenSound):
	if has_node(givenSound):
		get_node(givenSound).playing = false

func UpdateMusicLevel(givenLevel):
	if Global.musicOn:
		for i in range($Music.get_child_count()):
			if i < givenLevel:
				$Music.get_child(i).volume_db = -13
			else:
				$Music.get_child(i).volume_db = -80
	else:
		for music in $Music.get_children():
			music.volume_db = -80
