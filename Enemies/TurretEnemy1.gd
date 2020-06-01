extends "res://Enemies/BasicEnemy.gd"


var vertical_speed = 0.0

export (PackedScene) var Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		SPAWNING:
			position.y += (scroll_speed + vertical_speed) * delta
			$Area2D.type = "SpawningEnemy"
		ATTACKING:
			$Area2D.type = "AttackingEnemy"
			if $ShotTimer.is_stopped():
				$ShotTimer.start()
			position.y += (scroll_speed + vertical_speed) * delta
		DYING:
			$ShotTimer.stop()


func _on_GolemSprite_animation_finished():
	if $GolemSprite.animation == "Spawning":
		state = ATTACKING
		$GolemSprite.animation = "Attacking"
	elif $GolemSprite.animation == "Shooting":
		shoot_bullet()
		$GolemSprite.animation = "Attacking"


func shoot_bullet():
	$GolemSprite.animation = "Attacking"
	var new_bullet = Bullet.instance()
	new_bullet.position = $Position2D.position + position
	new_bullet.direction = mainnode.persistant_player.position - ($Position2D.position + position)
	HoopsNode.add_child(new_bullet)
	$ShootSound.play()


func _on_ShotTimer_timeout():
	$GolemSprite.animation = "Shooting"
