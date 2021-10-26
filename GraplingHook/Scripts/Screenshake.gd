extends Node

var magnitude

onready var frequency = $Frequency
onready var duration = $Duration
onready var shakeTween = $ShakeTween

onready var currentCamera = get_parent()

func Start(givenDura = 0.2, givenFreq = 15, givenMag = 2):
	magnitude = givenMag
	
	duration.wait_time = givenDura
	frequency.wait_time = givenFreq
	duration.start()
	frequency.start()
	
	NewShake()

func NewShake():
	var rand = Vector2()
	rand.x = rand_range(-magnitude, magnitude)
	rand.y = rand_range(-magnitude, magnitude)
	
	shakeTween.interpolate_property(currentCamera, "offset", currentCamera.offset, rand, frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shakeTween.start()

func ResetShake():
	shakeTween.interpolate_property(currentCamera, "offset", currentCamera.offset, Vector2.ZERO, frequency.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	shakeTween.start()

func FrequencyStep():
	NewShake()

func DurationStep():
	ResetShake()
	frequency.stop()
