extends Node2D

#Basically just define a bunch of a random patterns of enemies, then mix and match to spawn waves
#Grid definitions

#var top_grid = {30 : Vector2(48,-336), 31 : Vector2(144, -336), 32 : Vector2(240,-336), 33 : Vector2(336,-336), 34 : Vector2(432,-336), 35 : Vector2(528,-336), 36 : Vector2(624,-336), 37 : Vector2(720,-336),
#				20 : Vector2(48,-240), 21 : Vector2(144, -240), 22 : Vector2(240,-240), 23 : Vector2(336,-240), 24 : Vector2(432,-240), 25 : Vector2(528,-240), 26 : Vector2(624,-240), 27 : Vector2(720,-240),
#				10 : Vector2(48,-144), 11 : Vector2(144,-144), 12 : Vector2(240,-144), 13 : Vector2(336,-144), 14 : Vector2(432,-144), 15 : Vector2(528,-144), 16 : Vector2(624,-144), 17 : Vector2(720,-144),
#				00 : Vector2(48,-48), 01 : Vector2(144,-48), 02 : Vector2(240,-48), 03 : Vector2(336,-48), 04 : Vector2(432,-48), 05 : Vector2(528,-48), 06 : Vector2(624,-48), 07 : Vector2(720,-48),
#				}

var top_grid = {}
var right_grid = {}
var left_grid = {}
var bottom_grid = {}
var center_grid = {}


#Pull in enemy types
export (PackedScene) var BasicGolem
export (PackedScene) var Turret
export (PackedScene) var Runner

#Bosses
export(PackedScene) var PillarsOfResistance
export(PackedScene) var MimicAngel

export (PackedScene) var Arcology
var persistant_arcology

onready var MobNode = get_node("/root/Main/Mobs")

onready var EnemiesNode = MobNode.get_node("Enemies")

enum {PLAYING, OVER, BOSSINTRO, BOSS, BOSSOVER}
#BOSSINTRO puts the arcology at -300 from the necessary location
#BOSS stops the background from scrolling
#Should be able to go to BOSSOVER

var persistant_boss

var state = PLAYING

var wave_number = 0
var final_wave = 5

signal level_over
signal boss_fight
signal boss_over

# Called when the node enters the scene tree for the first time.
func _ready():
	build_top_grid()
	build_left_grid()
	build_right_grid()
	build_bottom_grid()
	build_center_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		PLAYING:
			pass
		OVER:
			if persistant_arcology.position.y < -250:
				persistant_arcology.position.y += 30.0 * delta
			if persistant_arcology.position.y >= -250:
				persistant_arcology.position.y = -250
				emit_signal("level_over")
				queue_free()
		BOSSINTRO:
			pass
		BOSS:
			pass
		BOSSOVER:
			pass

#Golems
func Basic_Eight():
	create_basic_golem(top_grid[02])
	create_basic_golem(top_grid[03])
	create_basic_golem(top_grid[04])
	create_basic_golem(top_grid[05])
	create_basic_golem(top_grid[12])
	create_basic_golem(top_grid[13])
	create_basic_golem(top_grid[14])
	create_basic_golem(top_grid[15])


func fill_screen():
	create_basic_golem(top_grid[0])
	create_basic_golem(top_grid[1])
	create_basic_golem(top_grid[2])
	create_basic_golem(top_grid[3])
	create_basic_golem(top_grid[4])
	create_basic_golem(top_grid[5])
	create_basic_golem(top_grid[6])
	create_basic_golem(top_grid[7])
	create_basic_golem(top_grid[8])


func flying_vee():
	create_basic_golem(top_grid[01])
	create_basic_golem(top_grid[07])
	create_basic_golem(top_grid[12])
	create_basic_golem(top_grid[16])
	create_basic_golem(top_grid[23])
	create_basic_golem(top_grid[25])
	create_basic_golem(top_grid[34])


func flanks():
	create_basic_golem(top_grid[00])
	create_basic_golem(top_grid[08])
	create_basic_golem(top_grid[10])
	create_basic_golem(top_grid[18])
	create_basic_golem(top_grid[20])
	create_basic_golem(top_grid[28])

#Turrets
func flanking_turrets():
	create_turret(center_grid[51])
	create_turret(center_grid[57])


func corner_turrets():
	create_turret(center_grid[10])
	create_turret(center_grid[60])
	create_turret(center_grid[68])
	create_turret(center_grid[18])


func center_turrets():
	create_turret(center_grid[43])
	create_turret(center_grid[45])
	create_turret(center_grid[65])
	create_turret(center_grid[63])


#Runners
#Never create two runners on the same x level at the same time!!
func center_flanks():
	create_runner(right_grid[05])
	create_runner(right_grid[15])
	create_runner(left_grid[05])
	create_runner(left_grid[15])
	

func bottom_corner_rush():
	create_runner(right_grid[08])
	create_runner(left_grid[08])


func top_corner_rush():
	create_runner(right_grid[01])
	create_runner(left_grid[01])


func create_basic_golem(grid_position):
	var new_golem = BasicGolem.instance()
	new_golem.state = new_golem.ATTACKING
	new_golem.position = grid_position
	new_golem.connect("kill", get_node("/root/Main"),"score_up")
	EnemiesNode.add_child(new_golem)


func create_turret(grid_position):
	var new_golem = Turret.instance()
	new_golem.state = new_golem.ATTACKING
	new_golem.position = grid_position
	new_golem.connect("kill", get_node("/root/Main"),"score_up")
	EnemiesNode.add_child(new_golem)


func create_runner(grid_position):
	var new_golem = Runner.instance()
	new_golem.state = new_golem.ATTACKING
	new_golem.position = grid_position
	new_golem.connect("kill", get_node("/root/Main"),"score_up")
	EnemiesNode.add_child(new_golem)


func build_top_grid():
	# 9 x 5 grid
	#key is y, x because fuck you that's why
	for i in range (0,6): #Vertical
		for j in range (0,9): #Horizontal
			var key = i * 10 + j
			var new_position = Vector2(j * 80 + 40, i * -80 - 40)
			top_grid[key] = new_position


func build_left_grid():
	# 9 x 5 grid
	#key is y, x because fuck you that's why
	for i in range (0,10): #Vertical
		for j in range (0,2): #Horizontal
			var key = j * 10 + i
			var new_position = Vector2(j * -80 - 40, i * 80 + 40)
			left_grid[key] = new_position
	


func build_right_grid():
	# 9 x 5 grid
	#key is y, x because fuck you that's why
	for i in range (0,10): #Vertical
		for j in range (0,2): #Horizontal
			var key = j * 10 + i
			var new_position = Vector2(j * 80 + 760, i * 80 + 40)
			right_grid[key] = new_position


func build_bottom_grid():
	# 9 x 5 grid
	#key is y, x because fuck you that's why
	for i in range (0,4): #Vertical
		for j in range (0,9): #Horizontal
			var key = i * 10 + j
			var new_position = Vector2(j * 80 + 40, i * 80 + 1000)
			bottom_grid[key] = new_position


func build_center_grid():
	for i in range (0,10): #Vertical
		for j in range (0,9): #Horizontal
			var key = i * 10 + j
			var new_position = Vector2(j * 80 + 40, i * 80 + 40)
			center_grid[key] = new_position


func level_end():
	persistant_arcology = Arcology.instance()
	persistant_arcology.position.y = -500
	get_node("/root/Main/Cutscenes").add_child(persistant_arcology)
	state = OVER


func Pillars_Boss_Fight():
	#put in position, start moving down
	persistant_boss = PillarsOfResistance.instance()
	persistant_boss.position.y = -960
	EnemiesNode.add_child(persistant_boss)
	state = BOSSINTRO
	#Stop screen from scrolling
	

func Mimic_Boss_Fight():
	persistant_boss = MimicAngel.instance()
	persistant_boss.position.y = -900
	EnemiesNode.add_child(persistant_boss)
	state = BOSSINTRO
