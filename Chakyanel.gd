extends Node2D

export (PackedScene) var Bullet

onready var MainNode = get_node("/root/Main")
onready var HoopsNode = MainNode.get_node("Mobs/Hoops")

enum {START, }
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func Angel_Actions():
	pass


func fork_shot():
	shoot_bullet(Vector2(0,-1))
	shoot_bullet(Vector2(0,-1))
	shoot_bullet(Vector2(0,-1))


func shoot_bullet(direction : Vector2):
	$GolemSprite.animation = "Attacking"
	var new_bullet = Bullet.instance()
	new_bullet.position = position
	new_bullet.direction = direction
	HoopsNode.add_child(new_bullet)
	$ShootSound.play()
