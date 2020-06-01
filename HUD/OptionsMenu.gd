extends Panel


onready var main_node = get_node("/root/Main")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func process(_delta):
	$SFXVolume/Volume.text = str(main_node.sound_volume)
	$MusicVolume/Volume.text = str(main_node.music_volume)
	


func _on_Return_pressed():
	hide()


func _on_SFX_minus_pressed():
	if main_node.sound_volume > 0:
		main_node.sound_volume -= 1


func _on_SFX_plus_pressed():
	if main_node.sound_volume < 10:
		main_node.sound_volume += 1




func _on_Music_minus_pressed():
	if main_node.music_volume > 0:
		main_node.music_volume -= 1


func _on_Music_plus_pressed():
	if main_node.music_volume < 10:
		main_node.music_volume += 1
