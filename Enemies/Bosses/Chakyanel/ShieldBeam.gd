extends Line2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#lerp alpha channel to zero, transparent out
	set_point_position(1, get_parent().angel.position - get_parent().position)
	if default_color.a >= 0:
		show()
		default_color.a -= delta
	else:
		hide()
