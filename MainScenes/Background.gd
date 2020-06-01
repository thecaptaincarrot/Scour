extends Node2D


var scroll_speed = 0
enum {SCROLLING, HIDDEN, RESET, STOPPED}

var state = HIDDEN
# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_speed = get_parent().SCROLL_SPEED



func _process(delta):
	match state:
		SCROLLING:
			show()
			position.y += scroll_speed * delta
		STOPPED:
			show()
		HIDDEN:
			hide()
		RESET:
			position.y = 0
			state = SCROLLING
