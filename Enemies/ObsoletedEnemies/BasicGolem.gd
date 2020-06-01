extends Node2D

export (PackedScene) var Hoop

onready var mainnode = get_node("/root/Main")
onready var mobnode = mainnode.get_node("Mobs")

onready var HoopsNode = mobnode.get_node("Hoops")

enum {ATTACKING, DYING, DEAD}

var state = ATTACKING

var FPS = 10.0 
var kill_time = 60.0 #2.5 seconds at level 1
var kill_speed = 20.0

#Background moves at 30 units per second
const SCROLLING_SPEED = 30.0
var vertical_speed = 50

var value = 1.0

var score_give = false

signal kill

var drop_ring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$RingSprite.hide()
	
	kill_speed = mainnode.player_killspeed



func _process(delta):
	$DeathSound.volume_db = -40 + (4 * mainnode.sound_volume)
	
	match state:
		ATTACKING:
			position.y = position.y + delta * vertical_speed
		
		DYING:
			if $Area2D.type != "Dying":
				$Area2D.type = "Dying"
			
			position.y = position.y + delta * SCROLLING_SPEED
			
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
				HoopsNode.add_child(new_hoop)
				drop_ring = false



func _on_Area2D_area_entered(_area):
	pass


func Kill_My_Self():
	if state == DEAD:
		queue_free()




func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()


func _on_DeathSound_finished():
	$DeathSound.stop()
