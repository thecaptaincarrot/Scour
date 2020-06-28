extends Node2D

export (PackedScene) var Bullet

onready var MainNode = get_node("/root/Main")
onready var HoopsNode = MainNode.get_node("Mobs/Hoops")

enum {DORMANT, START, IDLE, ATTACKING, UNPROTECTED}
var state = DORMANT

var shielded = true
var direction = Vector2(1,0)
var move_to = Vector2(0,0)
var speed_scalar = 100

var idle_position_right = Vector2(720 - 48, 96)
var idle_position_left = Vector2(48, 96)

var move_to_weight = 0.04
var x_distance_to_move_to
var y_distance_to_move_to
var t = 0

var scroll_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_speed = MainNode.SCROLL_SPEED
	show_angel_to_pylons()
	$Angel.position = Vector2(360,96)
	move_to = idle_position_right


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		DORMANT:
			if position.y < 0:
				position.y += delta * MainNode.SCROLL_SPEED
			else:
				state = START
				$IntroAnimationPlayer.play()
		START:
			if $IntroAnimationPlayer.is_playing() == false:
				$IntroAnimationPlayer.play("RaisePylons")
			x_distance_to_move_to = move_to.x - $Angel.position.x
			y_distance_to_move_to = move_to.y - $Angel.position.y
		IDLE:
			#lerp back and forth at the top
			if $Angel.position.distance_to(idle_position_right) <= 10:
				move_to = idle_position_left
				x_distance_to_move_to = move_to.x - $Angel.position.x
				y_distance_to_move_to = move_to.y - $Angel.position.y
			elif $Angel.position.distance_to(idle_position_left) <= 10:
				move_to = idle_position_right
				x_distance_to_move_to = move_to.x - $Angel.position.x
				y_distance_to_move_to = move_to.y - $Angel.position.y
			#!>!>!>>!>!!>!??!?!??!?!?!??!?!??!?!?!??!?!?!?!??!?!$Angel.position += Vector2(sin(x_distance_to_move_to*(move_to.x - $Angel.position.x)), sin(y_distance_to_move_to*(move_to.y - $Angel.position.y))) * delta
		ATTACKING:
			pass
		UNPROTECTED:
			pass


func Angel_Actions():
	pass


func fork_shot():
	shoot_bullet(Vector2(0,-1))
	shoot_bullet(Vector2(0,-1))
	shoot_bullet(Vector2(0,-1))


func shoot_bullet(direction : Vector2):
	$GolemSprite.animation = "Attacking"
	var new_bullet = Bullet.instance()
	new_bullet.position = position
	new_bullet.direction = direction
	HoopsNode.add_child(new_bullet)
	$ShootSound.play()


func show_angel_to_pylons():
	for N in $Pylon.get_children():
		N.angel = $Angel


func cast_Shield_Ray():
	for N in $Pylon.get_children():
		N.cast_beam()


func _on_IntroAnimationPlayer_animation_finished(anim_name):
	state = IDLE

