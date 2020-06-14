extends Node2D

export (PackedScene) var Hoop

onready var mainnode = get_node("/root/Main")
onready var mobnode = mainnode.get_node("Mobs")
onready var HoopsNode = mobnode.get_node("Hoops")

onready var Player = mainnode.persistant_player

enum {SPAWNING, ATTACKING, DYING, DEAD}

var state

var FPS = 10.0
var kill_time = 120.0 #The maximum FPS of the animation before it deletes the enemy
var kill_speed = 20.0

#Background moves at 30 units per second
var scroll_speed

export var value = 1.0
var score_give = false

signal kill

var drop_ring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$RingSprite.hide()
	
	scroll_speed = mainnode.SCROLL_SPEED
	
	kill_speed = mainnode.player_killspeed
	state = SPAWNING #This much be changed by each enemy for their own behavior



func _process(delta):
	$DeathSound.volume_db = -40 + (4 * mainnode.sound_volume)
	$ShootSound.volume_db = -40 + (4 * mainnode.sound_volume)
	
	match state:
		SPAWNING:
			$GolemSprite.animation = "Spawning"
		ATTACKING:
			if $Area2D.type != "AttackingEnemy":
				$Area2D.type = "AttackingEnemy"
			$RingSprite.hide()
			
			pass #Don't even set an animation here because anything could be happening
		
		DYING:
			if $Area2D.type != "Dying":
				$Area2D.type = "Dying"
			
			position.y = position.y + delta * scroll_speed
			
			$GolemSprite.animation = "Dying" #This is required
			
			$RingSprite.show()
			$RingSprite.play()
			
			if FPS <= kill_time:
				FPS += kill_speed * delta * 2
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
	if state == DYING:
		if drop_ring:
			var new_hoop = Hoop.instance()
			new_hoop.state = new_hoop.LAYING
			new_hoop.position = position + get_parent().position
			HoopsNode.add_child(new_hoop)
			drop_ring = false
	queue_free()


func _on_DeathSound_finished():
	$DeathSound.stop()
