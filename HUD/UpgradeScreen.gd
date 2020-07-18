extends Control

var killspeed
var killspeedtime = {}
var speed
var recoveryspeed
var bounce

var killspeed_cost_dict 
var speed_cost_dict 
var recoveryspeed_cost_dict 
var bounce_cost_dict 

var killspeedlevel
var bouncelevel
var speedlevel
var recoveryspeedlevel 

##Set this on ready
var killspeed_cost = 10
var speed_cost = 10
var recoveryspeed_cost = 10
var bounce_cost = 10

var KillSpeed_cost_text = "Cost: " + str(killspeed_cost)
var Speed_cost_text = "Cost: " + str(speed_cost)
var Recoveryspeed_cost_text = "Cost: " + str(recoveryspeed_cost)
var Bounce_cost_text = "Cost: " + str(bounce_cost)

onready var MainNode = get_node("/root/Main")

signal next_level

#placeholder costs to start
#upgrade costs: 10, 25, 75, 175

# Called when the node enters the scene tree for the first time.
func _ready():
	
	killspeed_cost_dict = MainNode.KILLSPEED_COST
	speed_cost_dict =  MainNode.SPEED_COST
	recoveryspeed_cost_dict =  MainNode.RECOVERYSPEED_COST
	bounce_cost_dict =  MainNode.BOUNCE_COST
	
	killspeed = MainNode.KILLSPEED_VALUES
	killspeedtime[1] = 50 / killspeed[1]  #Recalculate this instead of manual entry eventually
	killspeedtime[2] = 50 / killspeed[2]
	killspeedtime[3] = 50 / killspeed[3]
	killspeedtime[4] = 50 / killspeed[4]
	speed = MainNode.SPEED_VALUES
	recoveryspeed = MainNode.RECOVERY_VALUES
	bounce = MainNode.BOUNCE_VALUES
	
	update_texts()


func _process(_delta):
	if is_visible_in_tree():
		get_parent().clear_screen()


func update_texts():
	$Favor.text = "Favor: " + str(MainNode.favor)
	
	#Costs Texts
	get_level_from_main()
	update_costs()
	
	KillSpeed_cost_text = "Cost: " + str(killspeed_cost)
	Speed_cost_text = "Cost: " + str(speed_cost)
	Recoveryspeed_cost_text = "Cost: " + str(recoveryspeed_cost)
	Bounce_cost_text = "Cost: " + str(bounce_cost)
	
	$KillSpeed/Cost.text = KillSpeed_cost_text
	$Speed/Cost.text = Speed_cost_text
	$RecoverySpeed/Cost.text = Recoveryspeed_cost_text
	$Bounce/Cost.text = Bounce_cost_text
	
	if killspeedlevel >= 4:
		$KillSpeed/Cost.text = "MAX LEVEL"
	if speedlevel >= 4:
		$Speed/Cost.text = "MAX LEVEL"
	if recoveryspeedlevel >= 4:
		$RecoverySpeed/Cost.text = "MAX LEVEL"
	if bouncelevel >= 4:
		$Bounce/Cost.text = "MAX LEVEL"
	
	$KillSpeed/Level.text = "Level " + str(killspeedlevel)
	$Speed/Level.text = "Level " + str(speedlevel)
	$RecoverySpeed/Level.text = "Level " + str(recoveryspeedlevel)
	$Bounce/Level.text = "Level " + str(bouncelevel)
	
	$KillSpeed/Level/Description.text = str(killspeedtime[killspeedlevel]) + " seconds"
	$Speed/Level/Description.text = str(speed[speedlevel]) + " per second"
	$RecoverySpeed/Level/Description.text = str(recoveryspeed[recoveryspeedlevel]) + " per second"
	$Bounce/Level/Description.text = str(bounce[bouncelevel]) + " bounces"


func get_level_from_main():
	killspeedlevel = MainNode.killspeedlevel
	bouncelevel = MainNode.bouncelevel
	speedlevel = MainNode.speedlevel
	recoveryspeedlevel = MainNode.recoveryspeedlevel

func update_costs():
	get_level_from_main()
	killspeed_cost = killspeed_cost_dict[killspeedlevel]
	speed_cost = speed_cost_dict[speedlevel]
	recoveryspeed_cost = recoveryspeed_cost_dict[recoveryspeedlevel]
	bounce_cost = bounce_cost_dict[bouncelevel]


func _on_KillSpeed_pressed():
	if killspeedlevel >= 4:
		return
	
	if MainNode.favor >= killspeed_cost:
		killspeedlevel += 1
		MainNode.killspeedlevel += 1
		MainNode.favor -= killspeed_cost
		
		MainNode.player_killspeed = killspeed[killspeedlevel]
		MainNode.update_player_stats()
		
	update_texts()
	update_costs()
	


func _on_Speed_pressed():
	if speedlevel >= 4:
		return
	
	if MainNode.favor >= speed_cost:
		speedlevel += 1
		MainNode.speedlevel += 1
		MainNode.favor -= speed_cost
		
		MainNode.player_speed = speed[speedlevel]
		MainNode.update_player_stats()
		
	update_texts()
	update_costs()


func _on_RecoverySpeed_pressed():
	if recoveryspeedlevel >= 4:
		return
	
	if MainNode.favor >= recoveryspeed_cost:
		recoveryspeedlevel += 1
		MainNode.recoveryspeedlevel += 1
		MainNode.favor -= recoveryspeed_cost
		
		MainNode.player_recoveryspeed = recoveryspeed[recoveryspeedlevel]
		MainNode.update_player_stats()
		
	update_texts()
	update_costs()


func _on_Bounce_pressed():
	if bouncelevel >= 4:
		return
		
	if MainNode.favor >= bounce_cost:
		bouncelevel += 1
		MainNode.bouncelevel += 1
		MainNode.favor -= bounce_cost
		
		MainNode.player_bounce = bounce[bouncelevel]
		MainNode.update_player_stats()
		
	update_texts()
	update_costs()


func _on_continue_pressed():
	emit_signal("next_level")
