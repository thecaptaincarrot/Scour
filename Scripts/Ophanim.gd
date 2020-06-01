extends Node2D

export (PackedScene) var Hoop

enum {FINE, HURT, DEAD, DISABLED}
var state = DISABLED

var rings = 3
var speed = 250
var current_speed = 250

var bounce = 0
var recoveryspeed = 90.0
var killspeed = 20.0

var type = "Player"
var blink_timer = 0
var blink_count = 0

var screen_size

onready var Collision = $Area2D/CollisionShape2D
onready var Main = get_node("/root/Main")
onready var Mobs = Main.get_node("Mobs")
onready var Hoops = Mobs.get_node("Hoops")

signal PlayerHit
signal PlayerKilled

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


func _process(delta):
	if state == DISABLED or state == DEAD:
		return
	check_rings(rings)
	
	movement(delta)
	
	match state:
		HURT:
			if blink_timer <= 0:
				blink_timer = 0.05
				if $OphanimSprite.is_visible_in_tree():
					$OphanimSprite.hide()
					blink_count += 1
				else:
					$OphanimSprite.show()
			blink_timer -= delta
			
			if blink_count >=10:
				$OphanimSprite.show()
				blink_count = 0
				blink_timer = 0
				state = FINE


func check_rings(currentrings):
	if currentrings == 3:
		$OphanimSprite.animation = "3Rings"
		if Collision.shape.radius != 37.0:
			Collision.shape.radius = 37.0
		current_speed = speed
	elif currentrings == 2:
		$OphanimSprite.animation = "2Rings"
		if Collision.shape.radius != 25.0:
			Collision.shape.radius = 25.0
		current_speed = speed + speed / 5
	elif currentrings == 1:
		$OphanimSprite.animation = "1Rings"
		if Collision.shape.radius != 18.0:
			Collision.shape.radius = 18.0
		current_speed = speed + speed * 2 / 5
	elif currentrings == 0:
		$OphanimSprite.animation = "0Core"
		if Collision.shape.radius != 8.0:
			Collision.shape.radius = 8.0
		current_speed = speed * 2
	elif currentrings < 0:
		state = DEAD
		
func movement(delta):
	var velocity = Vector2()
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	
	position += velocity * delta
	
	position.x = clamp(position.x, 32, screen_size.x - 32)
	position.y = clamp(position.y, 32, screen_size.y - 32)


func _input(event):
	$ShotSound.volume_db = -80 + (8 * get_node("/root/Main").sound_volume)
	
	if state == DISABLED or state == DEAD:
		return
	#Shooting handled here
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if rings > 0:
			var mouse_position = get_global_mouse_position()
			var mouse_vector = mouse_position - position
			var direction_vector = mouse_vector.normalized()
			
			var new_hoop = Hoop.instance()
			new_hoop.position = position
			new_hoop.direction = direction_vector
			
			new_hoop.recovery_speed = recoveryspeed
			new_hoop.kill_speed = killspeed
			new_hoop.bounce = bounce
			
			Hoops.add_child(new_hoop)
			
			rings = rings - 1
			
			$ShotSound.play()
			#fire_delay = .1


func pickup_ring():
	if state == DISABLED or state == DEAD:
		return
	rings += 1


func _on_Area2D_area_entered(area):
	if state == DISABLED:
		return
	if area.type == "PickupHoop" or area.type == "BouncingHoop" or area.type == "FlyingHoop2":
		rings += 1
	if (area.type == "AttackingEnemy" or area.type == "Bullet" or area.type == "Boss") and state == FINE:
		if rings > 0:
			var new_hoop = Hoop.instance()
			new_hoop.state = new_hoop.STUNNED
			new_hoop.position = position
			new_hoop.direction = Vector2(randi(),randi()).normalized()
			new_hoop.speed = 300
			Hoops.call_deferred("add_child",new_hoop)
			state = HURT
			$InvulnTimer.start()
		else:
			emit_signal("PlayerKilled")
			$OphanimSprite.animation = "Dying"
		
		rings -= 1



func _on_InvulnTimer_timeout():
	if state == DISABLED:
		$OphanimSprite.show()
		return
	state = FINE
	$OphanimSprite.show()
	blink_timer = 0


func _on_ShotSound_finished():
	print("Stop Sound")
	$ShotSound.stop()
