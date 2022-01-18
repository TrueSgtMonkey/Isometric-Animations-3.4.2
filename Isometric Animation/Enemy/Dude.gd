extends KinematicBody

export (float) var speed = 3.0

var frame_num := 0
var curr_angle := 0
var frame_timer := Timer.new()
var move_timer := Timer.new()
var velocity := Vector3()
var gravity := 30.0

func _ready():
	frame_timer.one_shot = false
	frame_timer.wait_time = 1.0 / 24.0
	frame_timer.connect("timeout", self, "increase_frame")
	add_child(frame_timer)
	frame_timer.start()
	
	move_timer.one_shot = false
	move_timer.connect("timeout", self, "idle_move")
	add_child(move_timer)
	move_timer.start()
	
func _physics_process(delta):
	velocity.y -= gravity * delta
	if is_on_floor():
		velocity.y = 0
		
	move_and_slide(velocity, Vector3.UP, true)
	
func idle_move():
	velocity.x = 0
	velocity.z = 0
	var dir := Vector3((randi() % 3) - 1, 0, (randi() % 3) - 1)
	curr_angle = getCurrAngle(dir)
	dir = dir.normalized() * speed
	velocity += dir
	
func getCurrAngle(vel : Vector3):
	match vel:
		Vector3(-1, 0, 0):   #east
			return 0
		Vector3(-1, 0, 1):   #northeast
			return 1
		Vector3(0, 0, 1):   #north
			return 2
		Vector3(1, 0, 1):  #northwest
			return 3
		Vector3(1, 0, 0):  #west
			return 4
		Vector3(1, 0, -1): #southwest
			return 5
		Vector3(0, 0, -1):  #south
			return 6
		Vector3(-1, 0, -1):  #sourtheast
			return 7
		Vector3(0, 0, 0):   #no movement - keep same angle
			return curr_angle
	
# plays the sprite sheet animation one frame at a time in one dimension
func animation(st_frame : int, max_frame : int):
	pass
			
# angle: current direction the sprite is facing.
# st_frame: where we want our animation to start from in case there is 
#	 another animation - starts at 0 by default
func iso_animation(angle : int, st_frame : int = 0):
	pass

# called by a timer
func increase_frame():
	pass
