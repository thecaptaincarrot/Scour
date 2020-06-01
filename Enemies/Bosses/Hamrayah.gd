extends Node2D

export (PackedScene) var Hoop
export (PackedScene) var Bullet

export (PackedScene) var Explosion

onready var MainNode = get_node("/root/Main")
onready var MobsNode = MainNode.get_node("Mobs")
onready var HoopsNode = MobsNode.get_node("Hoops")

var ham_health = 3

var ham_rings = 0

var kill_speed = 20.0
var FPS = 10.0

signal kill

enum {UNDER, EMERGING, ATTACKING, SHOOTING, RECOVERING, DEMERGING, STUNNED, SPINNING, HURT, RESET, DEAD}
var state = RESET

var first_run = true

#Mord's timers:
	#Underground: 3 seconds
	#Pause: 1 second
	#Shots: .1 second
#Hamarayah's Timers:
	#Underground: 4 seconds
	#Pause: 1.5 second
	#Shots: .15 Seconds
# Called when the node enters the scene tree for the first time.
func _ready():
	#Mord Starting Location
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		UNDER:
			if $UndergroundTimer.is_stopped():
				$UndergroundTimer.start()

		EMERGING:
			if $GolemSprite.animation != "Emerging":
				set_animations("Emerging")
		ATTACKING:
			if $PauseTimer.is_stopped() == true:
				$PauseTimer.start()
			$Area2D.type = "Boss"
		SHOOTING:
			if $GunBurstTimer.is_stopped():
				$GunBurstTimer.start() 
		RECOVERING:
			if $PauseTimer.is_stopped():
				$PauseTimer.start()
		DEMERGING:
			if $GolemSprite.animation != "Demerging":
				set_animations("Demerging")
			$Area2D.type = "None"
		STUNNED:
			print($StunnedTimer.time_left)
			$Area2D.type = "StunnedBoss"
		SPINNING:
			$Area2D.type = "Dying"
			
			if FPS <= 80.0:
				FPS += kill_speed * delta
				$Area2D.type = "Dying"
			else:
				for _i in range(0,ham_rings):
					var new_hoop = Hoop.instance()
					new_hoop.state = new_hoop.STUNNED
					new_hoop.position = position + get_parent().position
					var direction =Vector2(randi(),randi()).normalized()
					new_hoop.direction = direction
					new_hoop.speed = 600.0
					HoopsNode.add_child(new_hoop)
					$ringSprite.hide()
					$ringSprite2.hide()
					$ringSprite3.hide()
					FPS = 10.0
					$HurtTimer.start()
				ham_health -= 1
				state = HURT
				check_health()
				ham_rings = 0
			$ringSprite.frames.set_animation_speed("Spin", FPS)
			$ringSprite2.frames.set_animation_speed("Spin", FPS)
			$ringSprite3.frames.set_animation_speed("Spin", FPS)
		
		HURT:
			pass
		DEAD:
			pass

func _on_UndergroundTimer_timeout():
	state = EMERGING


func _on_GolemSprite_animation_finished():
	match $GolemSprite.animation:
		"Emerging":
			state = ATTACKING
		"MouthOpen":
			state = SHOOTING
		"MouthClose":
			state = RECOVERING
		"Demerging":
			state = RESET
			set_animations("Closed")


func _on_PauseTimer_timeout():
	match state:
		ATTACKING:
			if first_run:
				state = RECOVERING
				first_run = false
			else:
				set_animations("MouthOpen")
		RECOVERING:
			state = DEMERGING



func _on_GunBurstTimer_timeout():
	if state == SHOOTING:
		set_animations("MouthClose")
		state = RECOVERING


func _on_ShotTimer_timeout():
	if state == SHOOTING:
		var new_bullet = Bullet.instance()
		new_bullet.position = $Shooter.position + position
		new_bullet.direction = MainNode.persistant_player.position - ($Shooter.position + position)
		HoopsNode.add_child(new_bullet)


func set_animations(animation):
	$Cracks1.animation = animation
	$Cracks2.animation = animation
	$GolemSprite.animation = animation


func hurt():
	ham_rings += 1

	set_animations("Default")
	state = STUNNED
	$StunnedTimer.start()
	match ham_rings:
		1:
			pass
			$ringSprite.show()
		2:
			$ringSprite2.show()
		3:
			$ringSprite3.show()
			state = SPINNING
			$StunnedTimer.stop()


func _on_StunnedTimer_timeout():
	if state == STUNNED:
		for _i in range(0,ham_rings):
			var new_hoop = Hoop.instance()
			new_hoop.state = new_hoop.STUNNED
			new_hoop.position = position + get_parent().position
			var direction =Vector2(randi(),randi()).normalized()
			new_hoop.direction = direction
			new_hoop.speed = 600.0
			HoopsNode.add_child(new_hoop)
		$ringSprite.hide()
		$ringSprite2.hide()
		$ringSprite3.hide()
		
		ham_rings = 0
		
		state = DEMERGING

func make_random_explosion():
	#Hard Coded because I honestly have no idea how to pull it
	var min_x = $Area2D/CollisionShape2D.position.x - $Area2D/CollisionShape2D.shape.extents.x
	var max_x = $Area2D/CollisionShape2D.position.x + $Area2D/CollisionShape2D.shape.extents.x
	
	var max_y = $Area2D/CollisionShape2D.position.y + $Area2D/CollisionShape2D.shape.extents.y
	var min_y = $Area2D/CollisionShape2D.position.y - $Area2D/CollisionShape2D.shape.extents.y
	
	var pos = Vector2(min_x + randi() % (int(max_x) - int(min_x)), min_y + randi() % (int(max_y) - int(min_y)))
	var new_explosion = Explosion.instance()
	
	new_explosion.position = pos
	add_child(new_explosion)
	


func _on_Explosion_Timer_timeout():
	if state == HURT or state == DEAD:
		make_random_explosion()


func _on_HurtTimer_timeout():
	if ham_health > 0:
		state = DEMERGING
		$Area2D.type = "None"
	else:
		$ExplosionTimer.stop()
		
func check_health():
	if ham_health >= 3:
		pass
	if ham_health == 2:
		$Cracks1.show()
	if ham_health == 1:
		$Cracks2.show()
		$HurtTimer.wait_time = 3.0
	if ham_health <= 0:
		$HurtTimer.wait_time = 4.0
		set_animations("Dead")
		$Area2D.type = "Dead"
		state = DEAD
		emit_signal("kill")
		#Big boom explosion	
