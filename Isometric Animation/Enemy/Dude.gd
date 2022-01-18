extends KinematicBody

export (float) var speed = 3.0

var velocity := Vector3()
var gravity := 30.0
var frame_num := 0
var curr_angle := 0
var last_frame : int

var frame_timer := Timer.new()
var move_timer := Timer.new()

func _ready():
	last_frame = $Sprite3D.hframes * $Sprite3D.vframes
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
	#play animation normally
	if st_frame < max_frame:
		frame_num += 1
		if frame_num > last_frame:
			printerr("out of bounds of $Sprite3D.hframes * $Sprite3D.vframes in ", name)
		if frame_num >= max_frame && frame_num <= last_frame:
			frame_num = st_frame
	elif st_frame > max_frame:
		frame_num -= 1
		if frame_num < 0:
			printerr("out of bounds (frame_num < 0) in ", name)
		if frame_num <= max_frame && frame_num >= 0:
			frame_num = st_frame
		
			
# angle: current direction the sprite is facing (CCW).
# st_frame: where we want our animation to start from in case there is 
#	 another animation - starts at 0 by default
func iso_animation(angle : int, st_angle : int = 0):
	if st_angle < 0:
		printerr("st_angle cannot be negative in ", name)
		return
	var curr_frame : int = frame_num % $Sprite3D.hframes
	frame_num = curr_frame + (angle * $Sprite3D.hframes)
	frame_num += st_angle * $Sprite3D.hframes
	
	animation((st_angle + angle) * $Sprite3D.hframes, (st_angle + angle + 1) * $Sprite3D.hframes - 1)
	
#	match angle:
#		0: #east
#			animation(st_angle * $Sprite3D.hframes, (st_angle + 1) * $Sprite3D.hframes - 1)
#		1: #northeast
#			animation((st_angle + 1) * $Sprite3D.hframes, (st_angle + 2) * $Sprite3D.hframes - 1)
#		2: #north
#		3: #northwest
#		4: #west
#		5: #southwest
#		6: #south
#		7: #southeast

# called by a timer
func increase_frame():
	iso_animation(curr_angle, 0)
	$Sprite3D.frame = frame_num
