extends Node2D

export (PackedScene) var Hoop
export (PackedScene) var Bullet

export (PackedScene) var Turret

onready var MainNode = get_node("/root/Main")
onready var MobsNode = MainNode.get_node("Mobs")
onready var HoopsNode = MobsNode.get_node("Hoops")
onready var EnemiesNode = MobsNode.get_node("Enemies")

onready var holes = {0 : $PortHole1, 1: $PortHole1, 2: $PortHole1, 3: $PortHole1}

onready var Mord = $Mord
onready var Hamrayah = $Hamrayah

enum {ATTACKING, EMERGING, UNDER, STUNNED, HURT}

var mord_state
var ham_state

var mord_hole
var ham_hole

var porthole_locations = {0 : Vector2(110,250), 1 : Vector2(110, 800), 2 : Vector2(610, 250), 3 : Vector2(610, 800)}

var turret_grid_locations = [40, 23, 25, 48, 68, 88, 64, 40, 60, 80, 103, 105]

var center_grid = {}

var turret1
var turret2
var turret3
var turret4
var turret5
var turret6

var number_turrets = 0
var max_turrets = 2

var positions = {}

enum {DORMANT, STATIONARY, START, ACTIVE}

var state = DORMANT

signal Boss_Defeated

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
	
	build_center_grid()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		DORMANT:
			if position.y < 0:
				position.y += delta * MainNode.SCROLL_SPEED
		START:
			#Mord Starting Location
			mord_hole = randi() % 4
			#Hamrayah Starting Location
			ham_hole = randi() % 4
			while mord_hole == ham_hole:
				ham_hole = randi() % 4
			Mord.position = porthole_locations[mord_hole]
			Hamrayah.position = porthole_locations[ham_hole]
			
			#Start at Emerging state
			Mord.state = Mord.EMERGING
			Hamrayah.state = Hamrayah.EMERGING
			
			create_turret(60)
			create_turret(68)
			Hamrayah.show()
			Mord.show()
			$TurretSpawnTimer.start()
			
			$NamePlate/AnimationPlayer.current_animation = "Fade In Fade out"
			$NamePlate/AnimationPlayer.play()
			state = ACTIVE
		
		ACTIVE:
			#Mord Behavior
			if Mord.state == Mord.RESET:
				mord_hole = randi() % 4
				while mord_hole == ham_hole:
					mord_hole = randi() % 4
				Mord.position = porthole_locations[mord_hole]
				Mord.state = Mord.UNDER
			
			#Hamrayah Behavior
			if Hamrayah.state == Hamrayah.RESET:
				ham_hole = randi() % 4
				while mord_hole == ham_hole:
					ham_hole = randi() % 4
				Hamrayah.position = porthole_locations[ham_hole]
				Hamrayah.state = Hamrayah.UNDER
			if Mord.state == Mord.DEAD and Hamrayah.state == Hamrayah.DEAD:
				$TurretSpawnTimer.stop()
				emit_signal("Boss_Defeated")


func build_center_grid():
	for i in range (0,11): #Vertical
		for j in range (0,9): #Horizontal
			var key = i * 10 + j
			var new_position = Vector2(j * 80 + 40, i * 80 + 40)
			center_grid[key] = new_position
	
	
	
func spawn_random_turret():
	if number_turrets < max_turrets:
		var possible_locations = turret_grid_locations
		#make a list of actual vector2's now
		
		var used_locations = []
		if EnemiesNode.get_child_count() > 0:
			for i in range(0,EnemiesNode.get_child_count()):
				used_locations.append(EnemiesNode.get_child(i).position)
		
		for location in used_locations:
			var loop_len = len(possible_locations)-1
			for i in range(0, loop_len):
				if i < len(possible_locations):
					if location == center_grid[possible_locations[i]]:
						possible_locations.remove(i)
						i = 0
						loop_len -= 1
			
		var grid_position = possible_locations[randi() % len(possible_locations)]
		create_turret(grid_position)


func create_turret(grid_position):
	var new_golem = Turret.instance()
	new_golem.state = new_golem.ATTACKING
	new_golem.position = center_grid[grid_position]
	new_golem.connect("kill", get_node("/root/Main"),"score_up")
	new_golem.connect("kill", self, "_turret_killed")
	new_golem.vertical_speed = 0
	new_golem.value = 1.0
	#check if there is a turret at the location specified
	EnemiesNode.add_child(new_golem)
	
	number_turrets += 1

func _turret_killed(_score):
	number_turrets -= 1


func _on_TurretSpawnTimer_timeout():
	spawn_random_turret()


func _on_Hamrayah_kill():
	$Mord/PauseTimer.wait_time = $Mord/PauseTimer.wait_time * 3.0 / 4.0
	$Mord/UndergroundTimer.wait_time = $Mord/UndergroundTimer.wait_time * 3.0 / 4.0
	$Mord/StunnedTimer.wait_time = $Mord/StunnedTimer.wait_time * 3.0 / 4.0
	$TurretSpawnTimer.wait_time = 6.0
	max_turrets = 6


func _on_Mord_kill():
	$Hamrayah/PauseTimer.wait_time = $Hamrayah/PauseTimer.wait_time * 3.0 / 4.0
	$Hamrayah/UndergroundTimer.wait_time = $Hamrayah/UndergroundTimer.wait_time * 3.0 / 4.0
	$Hamrayah/StunnedTimer.wait_time = $Hamrayah/StunnedTimer.wait_time * 3.0 / 4.0
	$TurretSpawnTimer.wait_time = 6.0
	max_turrets = 6
