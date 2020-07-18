extends Node2D

export (PackedScene) var Bullet
export (PackedScene) var Hoop
export (PackedScene) var FireTrail

onready var MainNode = get_node("/root/Main")
onready var MobsNode = MainNode.get_node("Mobs")
onready var HoopsNode = MobsNode.get_node("Hoops")
onready var EnemiesNode = MobsNode.get_node("Enemies")

onready var Player = MainNode.persistant_player

enum {DORMANT, START, IDLE, ATTACKING, BERSERK, DYING}
var state = DORMANT

var shielded = true
var direction = Vector2(1,0)
var move_to = Vector2(0,0)
var speed_scalar = 5
var offset = 30

var health = 3

var FPS = 10

var rings = 0

var move_to_weight = 0.03
var x_distance_to_move_to
var y_distance_to_move_to
var t = PI / 2

var returned = true

var pylon_destroyed_count = 0

var scroll_speed

signal Boss_Defeated
onready var Angel = $Angel

# Called when the node enters the scene tree for the first time.
func _ready():
	scroll_speed = MainNode.SCROLL_SPEED
	show_angel_to_pylons()
	Angel.position = Vector2(360,96)
	$Angel/ChakyanelSprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#position = delta * scalar * (sin(PI * (distance/(total_distance + offset)) + offset)
	
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
		IDLE:
			check_pylons()
			if returned:
				Angel.state = Angel.SHOTS
				t += delta
				$Angel.position = Vector2(312 * cos(t) + 360, 96)
			else:
				$Angel.position = lerp($Angel.position, Vector2(312 * cos(t) + 360, 96), .04)
				if $Angel.position.y <= 100:
					for N in $Pylon.get_children():
						N.emerge()
					returned = true
		ATTACKING:
			check_pylons()
			$Angel.position = lerp($Angel.position, Vector2(360,480), .08)
			Angel.state = Angel.WHEEL
		BERSERK:
			check_rings()
			var move_to_weight = (.08 - .02 * rings) * 4 - health
			$Angel.position = lerp ($Angel.position, move_to, .08)
			if ($Angel.position.x <= move_to.x + 4 or $Angel.position.x >= move_to.x - 4) and $ChaseTimer.is_stopped():
				$ChaseTimer.start()
			if rings >= 3:
				FPS += MainNode.player_killspeed * delta
				$Angel/RingSprite0.frames.set_animation_speed("default",FPS)
				$Angel/RingSprite1.frames.set_animation_speed("default",FPS)
				$Angel/RingSprite2.frames.set_animation_speed("default",FPS)
				if FPS >= 100:
					hurt_angel()


func Angel_Actions():
	pass


func show_angel_to_pylons():
	for N in $Pylon.get_children():
		N.angel = $Angel


func cast_Shield_Ray():
	for N in $Pylon.get_children():
		N.cast_beam()


func _on_IntroAnimationPlayer_animation_finished(anim_name):
	state = IDLE
	$PhaseTimer.start()
	for N in $Pylon.get_children():
		N.get_node("PylonArea").type = "RaisedPylon"
	$TextureRect/AnimationPlayer.play("FadeIn")


func move_angel(delta):
	var angel = $Angel
	angel.position = lerp(angel.position, move_to, move_to_weight)
	

func _on_PylonSprite_pylon_destroyed():
	pylon_destroyed_count += 1
	if pylon_destroyed_count >= 4:
		pylon_destroyed_count = 0
		#go to attack phase
		go_to_attacking()
		
		
func go_to_attacking():
	#go to attack phase
	pylon_destroyed_count = 0
	state = ATTACKING
	$Angel.reset_wheel()
	$PhaseTimer.wait_time = 20
	$PhaseTimer.start()
	for N in $Pylon.get_children():
		N.demerge()


func go_to_idle():
	state = IDLE
	pylon_destroyed_count = 0
	returned = false
	t = PI / 2
	$Angel.wheel_off()
	$PhaseTimer.wait_time = 10
	$PhaseTimer.start()


func _on_PhaseTimer_timeout():
	match state:
		IDLE:
			go_to_attacking()
		ATTACKING:
			go_to_idle()
			

func check_pylons():
	for N in $Pylon.get_children():
		if N.state == N.OK:
			return
	state = BERSERK
	Angel.shielded = false
	Angel.state = Angel.CHASE
	move_to =  Player.position
	$ChaseTimer.start()
	$PhaseTimer.stop()
	$Angel/Area2D.type = "UnprotectedBoss"


func _on_ChaseTimer_timeout():
	move_to =  Player.position


func check_rings():
	if rings == 0:
		$Angel/RingSprite0.hide()
		$Angel/RingSprite1.hide()
		$Angel/RingSprite2.hide()
	elif rings == 1:
		$Angel/RingSprite0.show()
		$Angel/RingSprite1.hide()
		$Angel/RingSprite2.hide()
	elif rings == 2:
		$Angel/RingSprite0.show()
		$Angel/RingSprite1.show()
		$Angel/RingSprite2.hide()
	elif rings == 3:
		$Angel/RingSprite0.show()
		$Angel/RingSprite1.show()
		$Angel/RingSprite2.show()
		MainNode.score_up(200)


func _on_StunTimer_timeout():
	for i in range(0,rings):
		var new_hoop = Hoop.instance()
		new_hoop.state = new_hoop.STUNNED
		new_hoop.position = Angel.position + get_parent().position
		var direction =Vector2(randi(),randi()).normalized()
		new_hoop.direction = direction
		new_hoop.speed = 600.0
		HoopsNode.add_child(new_hoop)
	$Angel/RingSprite0.hide()
	$Angel/RingSprite1.hide()
	$Angel/RingSprite2.hide()
	
	rings = 0
	FPS = 10


func hurt_angel():
	FPS = 10
	$ChaseTimer.stop()
	$Angel/RingSprite0.hide()
	$Angel/RingSprite1.hide()
	$Angel/RingSprite2.hide()
	for i in range(0,rings):
		var new_hoop = Hoop.instance()
		new_hoop.state = new_hoop.STUNNED
		new_hoop.position = Angel.position + get_parent().position
		var direction =Vector2(randi(),randi()).normalized()
		new_hoop.direction = direction
		new_hoop.speed = 600.0
		HoopsNode.add_child(new_hoop)
		print(Angel.position + get_parent().position)
	health -= 1
	rings = 0
	for N in $Pylon.get_children():
		N.recover()
	check_health()
	$Angel/Area2D.type = "ShieldedBoss"
	go_to_idle()


func player_killed():
	$Angel/RingSprite0.hide()
	$Angel/RingSprite1.hide()
	$Angel/RingSprite2.hide()
	rings = 0


func check_health():
	if health == 3:
		$Angel/ChakyanelSprite.animation = "NoDamage"
	elif health == 2:
		$Angel/ChakyanelSprite.animation = "OneDamage"
		$Angel/Shot_timer.wait_time = 0.25
	elif health == 1:
		$Angel/ChakyanelSprite.animation = "TwoDamage"
		$Angel/Shot_timer.wait_time = 0.2
	else:
		Angel.state = Angel.DEAD
		emit_signal("Boss_Defeated")


func _on_FireTrailTimer_timeout():
	if state == BERSERK:
		var new_firetrail = FireTrail.instance()
		new_firetrail.position = Angel.position
		if health == 2:
			new_firetrail.get_node("FireTimer").wait_time = 4
		elif health == 1:
			new_firetrail.get_node("FireTimer").wait_time = 5
		add_child(new_firetrail)
		
