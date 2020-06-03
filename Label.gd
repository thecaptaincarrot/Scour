extends Label


var highscores = {1 : ["Abram" , 20000], 2 : ["Ishaq" , 10000], 3 : ["Yaqub" , 5000], 4 : ["Yosef" , 2500] , 5 : ["Moesha" , 1000]}


# Called when the node enters the scene tree for the first time.
func _ready():
	text = highscores[1][0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
