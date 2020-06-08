extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func submit_high_score_name():
	#returns the name in the line edit
	#Basically just activate on enter presed or button
	hide()
	return $LineEdit.text
