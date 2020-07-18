extends Node2D

enum {OK,DAMAGED}
var state = OK

var angel_position
var angel

signal pylon_destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	$ShieldBeam.add_point($EmergedPosition.position, 0)
	$ShieldBeam.add_point(Vector2(0,0), 1)
	$PylonSprite.animation = "Lowered"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func cast_beam():
	if state == OK:
		if $PylonSprite.animation == "Emerging" or "Raised":
			$ShieldBeam.set_point_position(0, $EmergedPosition.position)
		elif $PylonSprite.animation == "Lowered" or "Demerge":
			$ShieldBeam.set_point_position(0, $LoweredPosition.position)
		print("casting")
		$ShieldBeam.default_color = Color(1.0,0,0,1.0)

func damage():
	$PylonArea.type = "DestroyedPylon"
	$PylonSprite.animation = "Destroyed"
	state = DAMAGED
	emit_signal("pylon_destroyed")

func recover():
	$PylonSprite.animation = "Respawn"
	state = OK


func emerge():
	if state != DAMAGED:
		$PylonSprite.animation = "Emerging"
		$PylonArea.type = "RaisedPylon"

func demerge():
	if state != DAMAGED:
		$PylonSprite.animation = "Demerge"
		$PylonArea.type = "LoweredPylon"


func _on_PylonSprite_animation_finished():
	if $PylonSprite.animation == "Demerge":
		$PylonSprite.animation = "Lowered"
	if $PylonSprite.animation == "Emerging":
		$PylonSprite.animation = "Raised"
	if $PylonSprite.animation == "Respawn":
		$PylonSprite.animation = "Lowered"
