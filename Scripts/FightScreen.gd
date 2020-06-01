extends Node2D


export (PackedScene) var H_WALL
export (PackedScene) var V_WALL

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	build_walls()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func build_walls():
	var walls_h = round(screen_size.x / 32) + 1
	var walls_v = round(screen_size.y / 32) + 1
	
	for i in range(0,walls_h):
		#Build bottom_walls
		var top_wall = H_WALL.instance()
		var bottom_wall = H_WALL.instance()
		
		add_child(top_wall)
		add_child(bottom_wall)
		
		top_wall.position.y = 0
		bottom_wall.position.y = screen_size.y
		
		top_wall.position.x = i * 32
		bottom_wall.position.x = i * 32
	
	for i in range(0,walls_v):
		#Build bottom_walls
		var left_wall = V_WALL.instance()
		var right_wall = V_WALL.instance()
		
		add_child(left_wall)
		add_child(right_wall)
		
		left_wall.position.x = 0
		right_wall.position.x = screen_size.x
		
		left_wall.position.y = i * 32
		right_wall.position.y = i * 32
