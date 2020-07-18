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
	print ("Ding")
	match wave_number:
		0:
			Small_Line()
		1:
			flanks()
			single_turret()
		2:
			center_turrets_less()
			Basic_Eight()
		3:
			center_compliment()
		4:
			center_turrets()
			flying_vee()
			Small_Line()
		5:
			Basic_Eight()
			corner_turrets()
		6:
			Pillars_Boss_Fight()

	
	wave_number += 1
