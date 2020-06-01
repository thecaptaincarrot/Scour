extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2aw
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$AudioStreamPlayer.volume_db = -40 + (4 * get_node("/root/Main").sound_volume)


func _on_AnimatedSprite_animation_finished():
	pass

func _on_AudioStreamPlayer_finished():
	queue_free()
