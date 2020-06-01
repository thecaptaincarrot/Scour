extends Area2D


var speed = 300.0
var direction = Vector2(1,1)

var type = "Bullet"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _process(delta):
	direction = direction.normalized()
	position += direction * speed * delta
