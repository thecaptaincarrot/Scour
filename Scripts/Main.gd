extends Node2D


export (PackedScene) var H_WALL
export (PackedScene) var V_WALL

export (PackedScene) var Player

export (PackedScene) var level1
export (PackedScene) var level2
export (PackedScene) var level3
export (PackedScene) var level4
export (PackedScene) var level5
export (PackedScene) var level6

export (PackedScene) var Arcology
export (PackedScene) var EndOfLevelCutscene
export (PackedScene) var EndOfBossCutscene

var persistant_player

var screen_size

enum {MAINMENU, GAME, MENU, CUTSCENE, BOSSCUTSCENE, CUTSCENEPLAYING, LEVELEND}

var state = MAINMENU

var score = 0
var favor = 0

var level = 0
#In an effort to improve editting, we are going to a top-down variable approach
#Several important constants that are redeclared in multiple places will
#instead be here in Main and inherited by future classes.
#Map Object Variables
const SCROLL_SPEED = 100.0

#Upgrade information
const KILLSPEED_VALUES = {1: 33.33, 2 : 50, 3 :  62.5, 4 : 83.3333}
const SPEED_VALUES = {1 : 400 , 2 : 500, 3: 800, 4: 700 }
const RECOVERY_VALUES = {1 : 50.0, 2 : 75.0, 3 : 100, 4: 125}
const BOUNCE_VALUES = {1 : 0, 2 : 1, 3 : 2, 4 : 3}

const KILLSPEED_COST = {1 : 10, 2 : 25, 3 : 75, 4 : 125}
const SPEED_COST = {1 : 10, 2 : 25, 3 : 75, 4 : 125}
const RECOVERYSPEED_COST = {1 : 10, 2 : 25, 3 : 75, 4 : 125}
const BOUNCE_COST = {1 : 10, 2 : 25, 3 : 75, 4 : 125}

var killspeedlevel = 1
var bouncelevel = 1
var speedlevel = 1
var recoveryspeedlevel = 1
 
#Player Variables, declarations here do not set anything due to them being set at newgame function
var player_bounce
var player_speed
var player_killspeed
var player_recoveryspeed

var lives = 3


var pre_cutscene_position = Vector2(0,0)

var music_volume = 0
var sound_volume = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	build_walls()
	
	$MainHUD.hide()



func _process(_delta):
	$MainHUD/Score/Scorecounter.text = str(score)
	$MainHUD/Level/LevelCounter.text = str(level)
	$MusicPlayer.volume_db = -50 + (4 * music_volume)
	match state:
		MENU:
			$MainHUD.hide()
			get_tree().paused = true
		GAME:
			$MainHUD.show()
			$PauseMenu.hide()
			get_tree().paused = false
			draw_lives()
		CUTSCENE:
			$Mobs.set_process(false)
			persistant_player.position = lerp(persistant_player.position, Vector2(screen_size.x / 2, screen_size.y * 3 / 4),.05)
			$KludgeTimer.start()
			if round(persistant_player.position.x) == screen_size.x / 2 and round(persistant_player.position.y) == screen_size.y * 3 / 4:
				clear_screen()
				var new_cutscene = EndOfLevelCutscene.instance() 
				
				$Cutscenes.add_child(new_cutscene)
				new_cutscene.connect("CutsceneOver", self, "go_to_upgrade_screen")
				persistant_player.hide()
				state = CUTSCENEPLAYING
				#Load and play cutscene over menu
		BOSSCUTSCENE:
			$Mobs.set_process(false)
			persistant_player.position = lerp(persistant_player.position, Vector2(screen_size.x / 2, screen_size.y * 3 / 4),.05)
			$KludgeTimer.start()
			if round(persistant_player.position.x) == screen_size.x / 2 and round(persistant_player.position.y) == screen_size.y * 3 / 4:
				var new_cutscene = EndOfBossCutscene.instance() 
				
				$Cutscenes.add_child(new_cutscene)
				new_cutscene.connect("CutsceneOver", self, "go_to_upgrade_screen")
				persistant_player.hide()
				state = CUTSCENEPLAYING
				#Load and play cutscene over menu
		CUTSCENEPLAYING:
			pass

func build_walls():
	var walls_h = round(screen_size.x / 32) + 1
	var walls_v = round(screen_size.y / 32) + 1
	
	for i in range(0,walls_h):
		#Build bottom_walls
		var top_wall = H_WALL.instance()
		var bottom_wall = H_WALL.instance()
		
		add_child(top_wall)
		add_child(bottom_wall)
		
		top_wall.position.y = 0
		bottom_wall.position.y = screen_size.y
		
		top_wall.position.x = i * 32
		bottom_wall.position.x = i * 32
	
	for i in range(0,walls_v):
		#Build bottom_walls
		var left_wall = V_WALL.instance()
		var right_wall = V_WALL.instance()
		
		add_child(left_wall)
		add_child(right_wall)
		
		left_wall.position.x = 0
		right_wall.position.x = screen_size.x
		
		left_wall.position.y = i * 32
		right_wall.position.y = i * 32

func NewGame():
	$TitleScreen.hide()
	$Background.state = $Background.RESET
	
	hard_clear_screen()
	
	state = GAME
	
	killspeedlevel = 1
	bouncelevel = 1
	speedlevel = 1
	recoveryspeedlevel = 1
	
	persistant_player = Player.instance()
	persistant_player.position.x = screen_size.x / 2
	persistant_player.position.y = screen_size.y * 3 / 4
	
	persistant_player.connect("PlayerKilled", self, "life_down")
	persistant_player.connect("PlayerHit",$MainCamera, "_initiate_shake")
	
	update_player_stats()
	$Mobs/Player.add_child(persistant_player)
	
	level = 0
	go_to_next_level()


func _input(event):
	#menuing handled here
	if event is InputEventKey and event.scancode == KEY_ESCAPE and event.pressed:
		if event.echo == false:
			match state:
				GAME:
					state = MENU
					$PauseMenu.show()
				MENU:
					state = GAME
					$OptionsMenu.hide()
					$PauseMenu.hide()


func score_up(value):
	score += value * 100
	favor += value


func go_to_next_level():
	level += 1
	$UpgradeScreen.hide()
	$Mobs.show()
	$Background.show()
	
	persistant_player.show()
	
	$Background.state = $Background.RESET
	if level == 1:
		create_level(level1)

	elif level == 2:
		create_level(level2)
		
	elif level == 3:
		create_level(level3)
		$Thanks.show()
		
	elif level == 4:
		create_level(level4)
		
	elif level == 5:
		create_level(level5)
		
	elif level == 6:
		create_level(level6)
		
	persistant_player.position.x = screen_size.x / 2
	persistant_player.position.y = screen_size.y * 3 / 4
	persistant_player.state = persistant_player.FINE
	state = GAME


func go_to_upgrade_screen():
	clear_levels()
	clear_screen()
	
	state = MENU
	
	$Mobs.hide()
	$Background.hide()
	$UpgradeScreen.show()
	
	$Background.state = $Background.HIDDEN
	
	$UpgradeScreen.update_texts()
	persistant_player.state = persistant_player.DISABLED
	

func level_end_cutscene_start():
	if persistant_player.state != persistant_player.DEAD:
		$Background.state = $Background.STOPPED
		persistant_player.state = persistant_player.DISABLED
		persistant_player.rings = 3
		pre_cutscene_position = persistant_player.position
		state = CUTSCENE


func boss_end_cutscene_start():
	if persistant_player.state != persistant_player.DEAD:
		$Background.state = $Background.STOPPED
		persistant_player.state = persistant_player.DISABLED
		persistant_player.rings = 3
		pre_cutscene_position = persistant_player.position
		state = CUTSCENE


func create_level(targetlevel):
	var new_level = targetlevel.instance()
	new_level.connect("level_over",self,"level_end_cutscene_start")
	new_level.connect("boss_fight",self,"boss_fight_start")
	$Level.add_child(new_level)


func update_player_stats():
	player_bounce = BOUNCE_VALUES[bouncelevel]
	player_speed = SPEED_VALUES[speedlevel]
	player_killspeed = KILLSPEED_VALUES[killspeedlevel]
	player_recoveryspeed = RECOVERY_VALUES[recoveryspeedlevel]
	
	print(player_recoveryspeed)
	
	persistant_player.speed = player_speed
	persistant_player.bounce = player_bounce
	persistant_player.recoveryspeed = player_recoveryspeed
	persistant_player.killspeed = player_killspeed


func clear_screen():
	for i in range(0,$Mobs/Enemies.get_child_count()):
		if $Mobs/Enemies.get_child(i) != persistant_player:
			$Mobs/Enemies.get_child(i).queue_free()
	for i in range(0,$Mobs/Hoops.get_child_count()):
		if $Mobs/Hoops.get_child(i) != persistant_player:
			$Mobs/Hoops.get_child(i).queue_free()
	for i in range(0,$Background.get_child_count()):
		if $Background.get_child(i).name != "MegaBackground":
			$Background.get_child(i).queue_free()
	for i in range(0,$Cutscenes.get_child_count()):
		if $Cutscenes.get_child(i).name != "MegaBackground":
			$Cutscenes.get_child(i).queue_free()
	persistant_player.rings = 3


func hard_clear_screen():
	for i in range(0,$Mobs/Enemies.get_child_count()):
		$Mobs/Enemies.get_child(i).queue_free()
	for i in range(0,$Mobs/Hoops.get_child_count()):
		$Mobs/Hoops.get_child(i).queue_free()
	for i in range(0,$Mobs/Player.get_child_count()):
		$Mobs/Player.get_child(i).queue_free()
	for i in range(0,$Cutscenes.get_child_count()):
		if $Cutscenes.get_child(i).name != "MegaBackground":
			$Cutscenes.get_child(i).queue_free()


func clear_levels():
	for i in range(0,$Level.get_child_count()):
		$Level.get_child(i).queue_free()


func game_over():
	$GameOver.show()
	$GameOver.update_score()


func _on_GameOver_return_to_menu():
	hard_clear_screen()
	clear_levels()
	
	$Mobs.hide()
	
	state = MAINMENU
	get_tree().paused = false
	
	
	$Background.state = $Background.HIDDEN
	
	$GameOver.hide()
	$MainHUD.hide()
	$TitleScreen.show()
	$Thanks.hide()
	
	$PauseMenu.hide()
	score = 0
	favor = 0


func _on_KludgeTimer_timeout():
	persistant_player.position = Vector2(screen_size.x / 2, screen_size.y * 3 / 4)


func boss_fight_start():
	$Background.state = $Background.STOPPED



func _on_Resume_pressed():
	state = GAME


func _on_Credits_pressed():
	$CreditsPanel.show()


func _on_Options_pressed():
	$OptionsMenu.show()


func _on_Continue_pressed():
	level -= 1
	persistant_player.rings = 3
	clear_levels()
	clear_screen()
	score = 0
	favor = 0
	lives = 3
	draw_lives()
	$GameOver.hide()
	go_to_next_level()


func _on_Button_pressed():
	pass # Replace with function body.


func _on_Instructions_pressed():
	$InstructionsScreen.show()


func _on_Instructions_Return_pressed():
	$InstructionsScreen.hide()


func draw_lives():
	var life1 = $MainHUD/LivesLabel/Life1
	var life2 = $MainHUD/LivesLabel/Life2
	var life3 = $MainHUD/LivesLabel/Life3
	var life4 = $MainHUD/LivesLabel/Life4
	
	#Just brute force it to avoid flashing and flickering
	match lives:
		0:
			life1.hide()
			life2.hide()
			life3.hide()
			life4.hide()
		1:
			life1.show()
			life2.hide()
			life3.hide()
			life4.hide()
		2:
			life1.show()
			life2.show()
			life3.hide()
			life4.hide()
		3:
			life1.show()
			life2.show()
			life3.show()
			life4.hide()
		4:
			life1.show()
			life2.show()
			life3.show()
			life4.show()


func life_down():
	#clear hoops
	for i in range(0,$Mobs/Hoops.get_child_count()):
		if $Mobs/Hoops.get_child(i) != persistant_player:
			$Mobs/Hoops.get_child(i).queue_free()
	#don't let anything drop rings anymore
	for i in range(0,$Mobs/Enemies.get_child_count()):
		if $Mobs/Enemies.get_child(i).state == $Mobs/Enemies.get_child(i).DYING:
			$Mobs/Enemies.get_child(i).drop_ring = false
	
	if lives > 0:
		lives -= 1
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t,"timeout")
		t.queue_free()
		persistant_player.position.x = screen_size.x / 2
		persistant_player.position.y = screen_size.y * 3 / 4
		persistant_player.rings = 3
		persistant_player.state = persistant_player.HURT
	else:
		game_over()
