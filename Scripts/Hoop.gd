extends KinematicBody2D


var direction = Vector2(0,-1)
var speed = 600.0
var velocity = Vector2(0,-1)

var friction = 0.05

var recovery_speed = 20.0
var kill_speed = 20.0
var bounce = 0

var FORCE = 600.0

var particle_speed = 100.0
var bounced = false


enum {FLYING, FLYING_2, BOUNCING, LAYING, STUNNED, KILLING}

var state = FLYING
var screen_size

var force_applied = false

var stunned_countdown = 3

onready var horizontal_tween = $BounceTween
onready var vertical_tween =  $BounceTween2

onready var Main = get_node("/root/Main")

var type = "Hoop"

var hit_something = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
	#recovery speed according to main
	recovery_speed = Main.RECOVERY_VALUES[Main.recoveryspeedlevel]


func _enter_tree():
	velocity = speed * direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#return to play area if fallen off because of dying enemy
	#just going to assume 
	if position.y >= 960:
		position.y = 940
	
	match state:
		FLYING:
			if $AnimatedSprite.animation != "Flying":
				$AnimatedSprite.animation = "Flying"
			if $Trail.emitting == false:
				$Trail.emitting = true
			$Trail.process_material.direction.x = -direction.x
			$Trail.process_material.direction.y = -direction.y
			$Trail.process_material.initial_velocity = speed + particle_speed
			
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				bounced = true
				velocity = velocity.bounce(collision_info.normal)
				bounce -= 1
				if bounce < 0:
					state = BOUNCING
				else:
					$Area2D.type = "FlyingHoop2"
		BOUNCING:
			if $AnimatedSprite.animation != "Bouncing":
				$AnimatedSprite.animation = "Bouncing"
			if type != "BouncingHoop":
				type = "BouncingHoop"
				$Area2D.type = "BouncingHoop"
			if $Trail.emitting == true:
				$Trail.emitting = false
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				velocity = velocity.bounce(collision_info.normal)
			velocity.x = lerp(velocity.x, 0, friction)
			velocity.y = lerp(velocity.y, 0, friction)
			
			if velocity.x <= 1 and velocity.y <= 1:
				state = LAYING
			
		LAYING:
			if $AnimatedSprite.animation != "Laying":
				$AnimatedSprite.animation = "Laying"
			if $Trail.emitting == true:
				$Trail.emitting = false
			if type != "PickupHoop":
				type = "PickupHoop"
				$Area2D.type = "PickupHoop"
			if $RigidShape.disabled == false:
				$RigidShape.disabled = true
			var player_vector = get_node("/root/Main/").persistant_player.position - position
			player_vector = player_vector.normalized()
			var _collision_info = move_and_collide(player_vector * recovery_speed * delta)
			
		
		STUNNED:
			if $AnimatedSprite.animation != "Stunned":
				$AnimatedSprite.animation = "Stunned"
			if type != "StunnedHoop":
				type = "StunnedHoop"
				$Area2D.type = "StunnedHoop"
			if $StunTimer.is_stopped():
				$StunTimer.start()
			var collision_info = move_and_collide(velocity * delta)
			if collision_info:
				velocity = velocity.bounce(collision_info.normal)
		KILLING:
			hide()
			pass
	
	

func _go_to_laying(_bad, _argument):
	$BounceTween.set_active(false)
	state = LAYING
	direction = Vector2(0,0)


func _on_Area2D_area_entered(area):
	if (state == LAYING or state == BOUNCING or (state == FLYING and bounced)) and area.type == "Player":
		queue_free()
	if (state == FLYING) and (area.type == "AttackingEnemy"  or area.type == "Emerging") and hit_something == false:
		hit_something = true
		area.get_parent().state = area.get_parent().DYING
		area.get_parent().kill_speed = kill_speed
		queue_free()
	#Bosses must have a function called "hit" that calls at this point
	if (state == FLYING) and (area.type == "Boss" or area.type == "StunnedBoss") and hit_something == false:
		hit_something = true
		area.get_parent().state = area.get_parent().STUNNED
		area.get_parent().kill_speed = kill_speed
		area.get_parent().hurt()
		queue_free()


func _on_StunTimer_timeout():
	state = LAYING


func _on_Hoop_body_entered(_body):
	state = BOUNCING


func _on_Hoop_body_shape_entered(_body_id, _body, _body_shape, _local_shape):
	state = BOUNCING
