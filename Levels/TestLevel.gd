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
	#just spawn the same thing over and over
	center_flanks()
	
	wave_number += 1
