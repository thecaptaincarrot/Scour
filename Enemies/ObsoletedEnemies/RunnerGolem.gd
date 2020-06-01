extends Node2D

export (PackedScene) var Hoop

onready var mainnode = get_node("/root/Main")
onready var mobnode = mainnode.get_node("Mobs")
onready var HoopNode = mobnode.get_node("Hoops")

onready var Player = mainnode.persistant_player

enum {ATTACKING, DYING, DEAD}

var state = ATTACKING

var FPS = 10.0 
var kill_time = 60.0 #2.5 seconds at level 1
var kill_speed = 20.0

#Background moves at 30 units per second
const SCROLLING_SPEED = 30.0
var vertical_speed = 100
var horizontal_speed = 150

var player_vector = Vector2(0,0)

var value = 4.0

var score_give = false

signal kill

var drop_ring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$RingSprite.hide()
	
	kill_speed = mainnode.player_killspeed
	
	#Directions. default facing right.
	if position.x >= 720:
		#Right Side
		horizontal_speed = -horizontal_speed
		$GolemSprite.flip_h = true


func _process(delta):
	$DeathSound.volume_db = -40 + (4 * mainnode.sound_volume)
	
	match state:
		ATTACKING:
			
			position.x += delta * horizontal_speed
			player_vector = get_player_position()
			position += player_vector * vertical_speed * delta
			
		DYING:
			if $Area2D.type != "Dying":
				$Area2D.type = "Dying"
			
			position.y += delta * SCROLLING_SPEED
			
			
			$GolemSprite.animation = "Dying"
			
			$RingSprite.show()
			$RingSprite.play()
			
			if FPS <= 60.0:
				FPS += kill_speed * delta
			else:
				emit_signal("kill",value)
				$DeathSound.play()
				state = DEAD
			$RingSprite.frames.set_animation_speed("Spin", FPS)
		DEAD:
			$RingSprite.hide()
			$GolemSprite.animation = "Dead"
			
			if drop_ring:
				var new_hoop = Hoop.instance()
				new_hoop.state = new_hoop.LAYING
				new_hoop.position = position + get_parent().position
				HoopNode.add_child(new_hoop)
				drop_ring = false



func _on_Area2D_area_entered(_area):
	pass


func Kill_My_Self():
	if state == DEAD:
		queue_free()


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


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_DeathSound_finished():
	$DeathSound.stop()
