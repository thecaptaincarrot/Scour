extends Node2D

onready var MainNode = get_node("/root/Main")
onready var MobsNode = MainNode.get_node("Mobs")
onready var HoopsNode = MobsNode.get_node("Hoops")
onready var EnemiesNode = MobsNode.get_node("Enemies")

export (PackedScene) var Bullet

enum {IDLE,SHOTS,WHEEL,CURTAIN,CHASE, DEAD}

var pew = false

var state = IDLE
var shielded = true

var player

var direction = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player = MainNode.persistant_player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		SHOTS:
			pass
		WHEEL:
			if pew == false and position.y >= 475:
				$HorizontalLine.show()
				$VerticalLine.show()
				$HorizontalLine.default_color = Color(200.0,200.0,200.0,64.0)
				$VerticalLine.default_color = Color(200.0,200.0,200.0,64.0)
				if $HorizontalLine.width <= 50:
					$HorizontalLine.width += 1
					$VerticalLine.width += 1
				else:
					randomize()
					if randi() % 2 == 0:
						direction = false
					else:
						direction = true
					pew = true
			elif pew:
				$VerticalLine.default_color = Color(1.0,0,0,1.0)
				$HorizontalLine.default_color = Color(1.0,0,0,1.0)
				$LaserWheel.type = "LaserWheel"
				var rotate = (4 - get_parent().health) * .5 + 1 
				if direction:
					rotate = -rotate
				
				$LaserWheel.rotation_degrees += rotate
				$HorizontalLine.rotation_degrees += rotate
				$VerticalLine.rotation_degrees += rotate
		CHASE:
			pass
		DEAD:
			hide()
			set_process(false)



func _on_Shot_timer_timeout():
	if state == SHOTS:
		fork_bullet()


func fork_bullet():
	#Forward Bullet
	var new_bullet = Bullet.instance()
	var target = player.position #Vector2
	var target_vector = player.position - position
	new_bullet.position = position
	new_bullet.direction = target_vector
	HoopsNode.add_child(new_bullet)
	
	var player_angle = atan2(target_vector.x, target_vector.y) + PI/2
	
	#left Bullet
	var new_x = cos(-player_angle + PI/6 + PI)
	var new_y = sin(-player_angle + PI/6 + PI)
	new_bullet = Bullet.instance()
	target_vector = Vector2(new_x, new_y).normalized()
	new_bullet.position = position
	new_bullet.direction = target_vector
	HoopsNode.add_child(new_bullet)
	#Right Bullet
	new_x = cos(-player_angle - PI/6 + PI)
	new_y = sin(-player_angle - PI/6 + PI)
	new_bullet = Bullet.instance()
	target_vector = Vector2(new_x, new_y).normalized()
	new_bullet.position = position
	new_bullet.direction = target_vector
	HoopsNode.add_child(new_bullet)
	 
	


func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.type == "FlyingHoop" and shielded == true:
		$ShieldSprite.modulate.a = 1.0
		get_parent().cast_Shield_Ray()

func reset_wheel():
	$HorizontalLine.rotation_degrees = 0
	$VerticalLine.rotation_degrees = 0
	$LaserWheel.rotation_degrees = 0
	
	$HorizontalLine.width = 1
	$VerticalLine.width = 1
	
	$LaserWheel.type = "off"
	

func wheel_off():
	$HorizontalLine.hide()
	$VerticalLine.hide()
	$LaserWheel.type = "Off"
	pew = false
