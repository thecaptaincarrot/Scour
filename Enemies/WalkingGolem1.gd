extends "res://Enemies/BasicEnemy.gd"


var vertical_speed = 30.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	match state:
		SPAWNING:
			state = ATTACKING
		ATTACKING:
			$GolemSprite.animation = "Attacking"
			position.y += (scroll_speed + vertical_speed) * delta
