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
			right_middle()
		1:
			flanks()
			center_turrets()
			bottom_corner_rush()
		2:
			Linebackers()
			flanks()
		3:
			Small_Shooter_Line()
			center_flanks()
		4:
			corner_turrets()
		5:
			gun_flanks()
			hard_right()
		6:
			Mimic_Boss_Fight()

	
	wave_number += 1
