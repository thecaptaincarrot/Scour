extends Node2D


signal CutsceneOver

 
# Called when the node enters the scene tree for the first time.
func _ready():
	print ("Cutscene Ready")
	$Ophanim.frame = 0
	$AnimationPlayer.current_animation = "LevelEndCutscene"
	$AnimationPlayer.play()
	$Ophanim.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("CutsceneOver")
