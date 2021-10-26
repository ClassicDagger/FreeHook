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

func _ready():
	rng.randomize()

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
