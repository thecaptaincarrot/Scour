extends AnimatedSprite

enum {OK,DAMAGED}
var state = OK

var angel_position
var angel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func cast_beam():
	if state == OK:
		if animation == "Emerging" or "Raised":
			$ShieldBeam.set_point_position(0, $EmergedPosition.position)
		elif animation == "Lowered":
			$ShieldBeam.set_point_position(0, $LoweredPosition.position)
		$ShieldBeam.points[1] = angel.position
		$ShieldBeam.color = $ShieldBeam.color + Color(0,0,0,255.0)
