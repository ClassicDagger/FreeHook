extends Node

var soundControl
var player
var optionsMenu
var rng = RandomNumberGenerator.new()

var musicOn = true
var soundOn = true

var savePath = "user://save.dat"
var playerData
var birdList = {
	"Cells" : false,
	"Caves" : false,
	"Dunes" : false,
	"Fortress" : false,
	"Palms" : false,
	}
var runTime = 0
var gemsCollected = []

var combo = 0
var comboTimer = 100
var notesGathered = []

func _ready():
	rng.randomize()

func _process(delta):
	if combo > 0:
		comboTimer -= 1
		if comboTimer <= 0:
			combo = 0
			ResetCombo()

func SaveData():
	var data = {
		"playerPosition" : Vector2.ZERO,
		"freedBirds" : null,
		"playTime" : 0,
		"collectedGems" : [],
		}
	
	data.playerPosition = player.position
	data.freedBirds = birdList
	data.playTime = runTime
	data.collectedGems = gemsCollected
	
	var file = File.new()
	var error = file.open(savePath, File.WRITE)
	if error == OK:
		file.store_var(data)
		file.close()
		
		print("Saved data!")

func LoadData():
	var file = File.new()
	if file.file_exists(savePath):
		var error = file.open(savePath, File.READ)
		if error == OK:
			playerData = file.get_var()
			file.close()
			birdList = playerData.freedBirds
			runTime = playerData.playTime
			gemsCollected = playerData.collectedGems

func Combo(givenNote):
	soundControl.Play("UIClick", 1 + (0.3 + combo))
	notesGathered.append(givenNote)
	comboTimer = 100
	combo += 1
	if combo == 5:
		soundControl.Play("Jingle")
		
		while notesGathered.size() != 0:
			notesGathered[0].FinishNote(5 - notesGathered.size())
			notesGathered.remove(0)
		print(notesGathered.size())
		combo = 0
		comboTimer = 100

func ResetCombo():
	for note in notesGathered:
		note.ResetNote()
	notesGathered.clear()
