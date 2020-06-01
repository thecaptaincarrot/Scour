extends "res://Enemies/BasicEnemy.gd"


var vertical_speed = 75
var horizontal_speed = 200

var player_vector = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _process(delta):
	match state:
		SPAWNING:
			if position.x >= 720:
				#Right Side
				horizontal_speed = -horizontal_speed
				$GolemSprite.flip_h = true
			state = ATTACKING
		ATTACKING:
			position.x += delta * horizontal_speed
			player_vector = get_player_position()
			position.y += player_vector.y * vertical_speed * delta

func get_player_position():
	#returns a vector2 in the negative or positive direction to point at the player.
	if Player.position.x < position.x and horizontal_speed > 0:
		return Vector2(0,0)
	if Player.position.x > position.x and horizontal_speed < 0:
		return Vector2(0,0)
	
	if Player.position.y > position.y:
		#Player is below me
		return Vector2(0,1)
	elif Player.position.y < position.y:
		#Player is above me
		return Vector2(0,-1)
	else:
		return Vector2(0,0)
