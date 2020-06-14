extends "res://Levels/LevelTemplate.gd"




# Called when the node enters the scene tree for the first time.
func _ready():
	Spawn_Next_Wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		BOSSINTRO:
			if persistant_pillar.position.y >= 0:
				print("BossTime")
				emit_signal("boss_fight")
				persistant_pillar.state = persistant_pillar.START
				state = BOSS
		BOSS:
			pass
		BOSSOVER:
			pass


func Spawn_Next_Wave():
	print ("Ding")
	match wave_number:
		0:
			Basic_Eight()
			flanks()
		1:
			flanking_turrets()
			Basic_Eight()
		2:
			Basic_Eight()
			bottom_corner_rush()
		3:
			top_corner_rush()
			flying_vee()
		4:
			flanks()
			Basic_Eight()
			bottom_corner_rush()
		5:
			top_corner_rush()
			bottom_corner_rush()
			fill_screen()
		6:
			fill_screen()
			flanking_turrets()
		7:
			Basic_Eight()
		8:
			Pillars_Boss_Fight()

	
	wave_number += 1
