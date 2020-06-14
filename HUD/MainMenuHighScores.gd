extends Control

var defaulthighscores = {"1" : ["Abram" , 20000], "2" : ["Ishaq" , 10000], "3" : ["Yaqub" , 5000], "4" : ["Yosef" , 2500] , "5" : ["Moesha" , 1000]}
onready var MainNode = get_node("/root/Main")

# Called when the node enters the scene tree for the first time.
func _ready():
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func update():
	var highscores = MainNode.highscores
	
	$Panel/HighScoreName1.text = "1. " + highscores["1"][0]
	$Panel/HighScoreName1/HighScoreValue1.text = str(highscores["1"][1])
	
	$Panel/HighScoreName2.text = "2. " + highscores["2"][0]
	$Panel/HighScoreName2/HighScoreValue2.text = str(highscores["2"][1])

	$Panel/HighScoreName3.text = "3. " + highscores["3"][0]
	$Panel/HighScoreName3/HighScoreValue3.text = str(highscores["3"][1])

	$Panel/HighScoreName4.text = "4. " + highscores["4"][0]
	$Panel/HighScoreName4/HighScoreValue4.text = str(highscores["4"][1])

	$Panel/HighScoreName5.text = "5. " + highscores["5"][0]
	$Panel/HighScoreName5/HighScoreValue5.text = str(highscores["5"][1])


func reset():
	MainNode.highscores = defaulthighscores
	MainNode.save_data()
	
	update()


func open_menu():
	update()
	show()


func _on_ReturnToMenu_pressed():
	hide()


func _on_Reset_pressed():
	$Panel2.show()
	$Panel/ReturnToMenu.disabled = true
	$Panel/Reset.disabled = true


func _on_NoButton_pressed():
	$Panel2.hide()
	$Panel/Reset.disabled = false
	$Panel/ReturnToMenu.disabled = false


func _on_YesButton_pressed():
	$Panel2.hide()
	$Panel/Reset.disabled = false
	$Panel/ReturnToMenu.disabled = false
	
	reset()
