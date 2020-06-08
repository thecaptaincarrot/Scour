extends Control

onready var mainnode = get_node("/root/Main")

signal return_to_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	update_highscore_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	emit_signal("return_to_menu")


func update_score():
	$Panel/FinalScore.text = "Score: " + str(mainnode.score)


func disable_buttons():
	$Panel/ReturnToMenu.disabled = true
	$Panel/Continue.disabled = true


func enable_buttons():
	$Panel/ReturnToMenu.disabled = false
	$Panel/Continue.disabled = false


func High_Score_Name_Submitted():
	var name = $NameEntryPanel.submit_high_score_name()
	var score = mainnode.score
	
	mainnode.update_high_scores(name, score)
	
	mainnode.save_data()
	
	update_highscore_text()
	
	enable_buttons()
	


func update_highscore_text():
	var highscores = mainnode.highscores
	
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
