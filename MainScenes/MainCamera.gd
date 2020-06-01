extends Camera2D

export var amplitude  = 6.0
export var duration = 0.8
export(float, EASE) var DAMP_EASING = 1.0
export var shake = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shake:
		var damping = ease($ShakeTimer.time_left / $ShakeTimer.wait_time, DAMP_EASING)
		offset = Vector2(
			rand_range(amplitude, -amplitude) * damping,
			rand_range(amplitude, -amplitude) * damping
		)


func _on_ShakeTImer_timeout():
	shake = false

func _initiate_shake():
	shake = true
	$ShakeTimer.start()
