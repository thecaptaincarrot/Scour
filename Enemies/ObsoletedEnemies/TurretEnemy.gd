extends Node2D

export (PackedScene) var Hoop

onready var mainnode = get_node("/root/Main")
onready var MobsNode = mainnode.get_node("Mobs")
onready var HoopsNode = MobsNode.get_node("Hoops")

enum {EMERGING, ATTACKING, DORMANT, SHOOTING, DYING, DEAD}

var state = "Attacking"

var FPS = 10.0 
var kill_time = 60.0 #2.5 seconds at level 1
var kill_speed = 20.0

#Background moves at 30 units per second
var vertical_speed = 30
const SCROLLING_SPEED = 30.0

var value = 2.0

var score_give = false

export (PackedScene) var Bullet

signal kill

var drop_ring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$RingSprite.hide()
	state = EMERGING
	
	kill_speed = mainnode.player_killspeed



func _process(delta):
	$DeathSound.volume_db = -40 + (4 * mainnode.sound_volume)
	$ShootSound.volume_db = -40 + (4 * mainnode.sound_volume)
	match state:
		EMERGING:
			if $Area2D.type != "Emerging":
				$Area2D.type = "Emerging"
			$GolemSprite.animation = "Emerge"
			position.y = position.y + delta * vertical_speed
		ATTACKING:
			position.y = position.y + delta * vertical_speed
		SHOOTING:
			position.y = position.y + delta * vertical_speed
		DYING:
			if $Area2D.type != "Dying":
				$Area2D.type = "Dying"
			$GolemSprite.animation = "Dying"
			position.y = position.y + delta * vertical_speed
			
			$RingSprite.show()
			$RingSprite.play()
			
			if FPS <= 60.0:
				FPS += kill_speed * delta
			else:
				emit_signal("kill",value)
				state = DEAD
				$DeathSound.play()
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
	if state == "Dead":
		queue_free()


func _on_ShotTimer_timeout():
	if state == ATTACKING:
		$GolemSprite.animation = "Shooting"


func _on_GolemSprite_animation_finished():
	if $GolemSprite.animation == "Shooting":
		if $StopShooting.is_visible_in_tree():
			$GolemSprite.animation = "Attacking"
			var new_bullet = Bullet.instance()
			new_bullet.position = $Position2D.position + position
			new_bullet.direction = mainnode.persistant_player.position - ($Position2D.position + position)
			HoopsNode.add_child(new_bullet)
			$ShootSound.play()
	if $GolemSprite.animation == "Dead":
		queue_free()
	if $GolemSprite.animation == "Emerge":
		state = ATTACKING
		$GolemSprite.animation = "Attacking"
		$Area2D.type = "AttackingEnemy"


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	if state == DYING:
		if drop_ring:
			var new_hoop = Hoop.instance()
			new_hoop.state = new_hoop.LAYING
			new_hoop.position = position + get_parent().position
			HoopsNode.add_child(new_hoop)
			drop_ring = false
	queue_free()


func _on_AudioStreamPlayer_finished():
	$DeathSound.stop()


func _on_StopShooting_screen_exited():
	state = DORMANT
