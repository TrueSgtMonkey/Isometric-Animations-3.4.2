extends KinematicBody

export (float) var speed = 6.0
export (float) var mouseSensitivity = 0.007
export (float) var jumpSpeed = 13.5
export (float) var cutHeight = 0.35
export (float) var sprintMultiplier = 1.75

const gravity := 30

var velocity := Vector3()
var colliderVelocity := Vector3()
var desiredVelocity := Vector3()
var isJumping := false
var grounded := false
var hasJumped := false
var jumpPressed := false
var isSprinting := false
var groundedTimer := Timer.new()
var jumpTimer := Timer.new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	groundedTimer = addTimer(groundedTimer, 0.2, "coyoteOut")
	jumpTimer = addTimer(jumpTimer, 0.2, "jumpBufferOut")
	
func _physics_process(delta):
	desiredVelocity = (move().normalized() * speed * 
		(sprintMultiplier if isSprinting else 1))
	
	var colVel = colliderVelocity
	
	if !is_on_floor():
		velocity.y -= gravity * delta
		if abs(desiredVelocity.x) > 0:
			velocity.x = desiredVelocity.x
		if abs(desiredVelocity.z) > 0:
			velocity.z = desiredVelocity.z
	else:
		velocity = desiredVelocity
		grounded = true
		groundedTimer.start()
		hasJumped = false
		colVel *= delta
		if (colliderVelocity == Vector3() || 
			(colliderVelocity.x != 0 || colliderVelocity.z != 0)):
			velocity.y = 0
		
	if grounded && isJumping && !hasJumped:
		velocity.y += jumpSpeed
		hasJumped = true
			
	if is_on_ceiling() && velocity.y > 0:
		velocity.y *= -0.25
	
	slope(get_slide_count())
	move_and_slide(velocity + colVel, Vector3.UP, true)
	
func _input(event):
	if event.is_action_released("JUMP"):
		if(velocity.y > 0):
			velocity.y *= cutHeight
		jumpPressed = false
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Pivot.rotate_y(-event.relative.x * mouseSensitivity)
		$Pivot/Camera.rotate_x(-event.relative.y * mouseSensitivity)
		$Pivot/Camera.rotation.x = clamp($Pivot/Camera.rotation.x, -1.5, 1.5)
	
func move():
	var movement := Vector3()
	if Input.is_action_pressed("FORWARD"):
		movement -= $Pivot.transform.basis.z 
	if Input.is_action_pressed("BACKWARD"):
		movement += $Pivot.transform.basis.z 
	if Input.is_action_pressed("LEFT"):
		movement -= $Pivot.transform.basis.x 
	if Input.is_action_pressed("RIGHT"):
		movement += $Pivot.transform.basis.x 
	isSprinting = Input.is_action_pressed("SPRINTING")
	if Input.is_action_pressed("JUMP") && !jumpPressed:
		jumpTimer.start()
		isJumping = true
		jumpPressed = true
	return movement
	
func slope(slides : int):
	if slides:
		colliderVelocity = Vector3.ZERO
		for i in slides:
			var touched = get_slide_collision(i)
			if(touched.collider.has_method("getVelocity")):
				colliderVelocity = touched.collider.getVelocity()
			else:
				colliderVelocity = touched.collider_velocity
			if touched.collider.has_method("getRotation"):
				$Pivot.rotate_y(touched.collider.getRotation())
	else:
		# If we don't get any slides for some reason, this is the backup
		getPlatformBelow()
	
func getPlatformBelow():
	var result = rayShot(Vector3(0, -10, 0))
	if(result && result.collider is KinematicBody):
		# we'll have to put the getVelocity() functions in our moving platforms
		if(result.collider.has_method("getVelocity")):
			colliderVelocity = result.collider.getVelocity()
		else:
			print("There was no getVelocity() function!")
			
		if result.collider.has_method("getRotation"):
			$Pivot.rotate_y(result.collider.getRotation())
	
func coyoteOut():
	grounded = false
	
func jumpBufferOut():
	isJumping = false
	
func addTimer(timer : Timer, wait : float, function : String):
	timer.wait_time = wait
	timer.one_shot = true
	timer.connect("timeout", self, function)
	add_child(timer)
	return timer

# Shortcut function so that I don't have to remember how to write this
func rayShot(vec : Vector3):
	var space_state = get_world().direct_space_state
	return space_state.intersect_ray(global_transform.origin, vec, [self])
