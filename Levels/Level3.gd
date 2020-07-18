extends "res://Levels/LevelTemplate.gd"




# Called when the node enters the scene tree for the first time.
func _ready():
	Spawn_Next_Wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		BOSSINTRO:
			if persistant_boss.position.y >= 0:
				print("BossTime")
				emit_signal("boss_fight")
				persistant_boss.state = persistant_boss.START
				state = BOSS
		BOSS:
			pass
		BOSSOVER:
			pass


func Spawn_Next_Wave():
	match wave_number:
		0:
			Small_Shooter_Line()
		1:
			flanks()
			center_turrets()
		2:
			center_turrets_less()
			Linebackers()
		3:
			flying_vee()
			single_turret()
			Small_Shooter_Line()
		4:
			corner_turrets()
			Linebackers()
		5:
			Linebackers()
			gun_flanks()
		6:
			level_end()

	
	wave_number += 1
