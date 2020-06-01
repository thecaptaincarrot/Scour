extends Node2D

export (PackedScene) var Hoop

onready var mainnode = get_node("/root/Main")

enum {ATTACKING, DYING, DEAD}

var state = "Attacking"

var FPS = 10.0 
var kill_time = 60.0 #2.5 seconds at level 1
var kill_speed = 20.0

var vertical_speed = 40

var value = 1.0

var score_give = false

signal kill

var drop_ring = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$RingSprite.hide()
	
	#get kill_speed stuff from Main



func _process(delta):
	if state == "Attacking":
		position.y = position.y + delta * vertical_speed
	
	if state == "Dying":
		if $Area2D.type != "Dying":
			$Area2D.type = "Dying"
		
		$GolemSprite.animation = "Dying"
		
		$RingSprite.show()
		$RingSprite.play()
		
		if FPS <= 60.0:
			FPS += kill_speed * delta
		else:
			emit_signal("kill",value)
			state = "Dead"
		$RingSprite.frames.set_animation_speed("Spin", FPS)
	if state == "Dead":
		$RingSprite.hide()
		$GolemSprite.animation = "Dead"
		
		if drop_ring:
			var new_hoop = Hoop.instance()
			new_hoop.state = new_hoop.LAYING
			new_hoop.position = position + get_parent().position
			mainnode.add_child(new_hoop)
			drop_ring = false



func _on_Area2D_area_entered(area):
	pass


func Kill_My_Self():
	if state == "Dead":
		queue_free()
