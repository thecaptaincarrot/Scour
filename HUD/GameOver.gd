extends Control

onready var mainnode = get_node("/root/Main")

signal return_to_menu


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	emit_signal("return_to_menu")


func update_score():
	$Panel/FinalScore.text = "Score: " + str(mainnode.score)
