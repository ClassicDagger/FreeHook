extends AnimatedSprite

onready var talkLabel = $Talk/TalkLabel
onready var talkTween = $TalkTween
onready var talkCooldown = $TalkCooldown
onready var talkSoundCooldown = $TalkSoundCooldown

var onCooldown = false

var talkedCounter = 0

var textSpeed = 0.06
var vagabondTextSpeed = 0.05

const speech1 = "Well, well, look who's back!"
const speech2 = "Oh, it's you again. Have you given up yet?"
const laughTexts = ["Ha ha! That one looked like it hurt!", "It sure is cozy in these cells!", "I got everything I need right in this cell!", "I'm glad I don't have to worry about falling in here!", "Funny seeing you here! Ha Ha!", "Giving up isn't so bad when you can be with me all the time!"]

const vagabondIntro = "What a [shake rate=5 level=8] pleasant [/shake] surprise! I never thought I would meet another vagabond here."
const vagabondSpeech1 = "Yes, how great it is to [color=#d26471] keep moving! [/color]"
const vagabondSpeech2 = "Even when I think I'm [color=#d26471] tied down. [/color] I must always [color=#d26471] keep moving. [/color]"

var vagabond = false

func _ready():
	if global_position.y <= 200:
		vagabond = true
		textSpeed = vagabondTextSpeed

func PlayerEntered(body):
	if !onCooldown:
		var givenTalk = ""
		if vagabond:
			if talkedCounter == 0:
				givenTalk = vagabondIntro
			elif talkedCounter == 1:
				givenTalk = vagabondSpeech1
			else:
				givenTalk = vagabondSpeech2
		else:
			if talkedCounter == 0:
				givenTalk = speech1
			elif talkedCounter == 1:
				givenTalk = speech2
			elif body.velocity.y > 10:
				givenTalk = laughTexts[Global.rng.randi_range(0, 6)]
		
		if givenTalk != "":
			TalkSound()
			talkedCounter += 1
			talkSoundCooldown.wait_time = Global.rng.randf_range(.3, .5)
			talkSoundCooldown.start()
			talkLabel.modulate = Color(1, 1, 1, 1)
			animation = "Talking"
			talkLabel.percent_visible = 0
			talkLabel.bbcode_text = "[center]" + givenTalk
			
			talkTween.interpolate_property(talkLabel, "percent_visible", 0, 1, textSpeed * givenTalk.length())
			talkTween.start()
			
			talkCooldown.wait_time = 15
			if vagabond:
				talkCooldown.wait_time = 10
			talkCooldown.start()
			onCooldown = true
			
			yield(talkTween, 'tween_completed')
			animation = "Idle"
			talkSoundCooldown.stop()
			talkTween.interpolate_property(talkLabel, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
			talkTween.start()

func RecoverCooldown():
	onCooldown = false
	talkCooldown.stop()

func TalkSound():
	Global.soundControl.Play("OldManTalking")
