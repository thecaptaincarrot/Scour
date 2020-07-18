extends "res://Levels/LevelTemplate.gd"




# Called when the node enters the scene tree for the first time.
func _ready():
	Spawn_Next_Wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
			Tutorial()
		1:
			Small_Line()
		2:
			flanks()
		3:
			flying_vee()
		4:
			Basic_Eight()
		5:
			pass
		6:
			level_end()
	wave_number += 1
