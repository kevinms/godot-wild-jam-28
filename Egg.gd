extends KinematicBody

var speed = 3.0
var gravity = 2.0
var velocity: Vector3

var spin_max_speed = 0.2
var lean_speed = 2.0
var fall_angle = PI/2.4

var prev_pos: Vector3
var lean_angle: float
var spin_speed: float

func _ready():
	prev_pos = global_transform.origin

func lean_dir() -> float:
	if Input.is_action_pressed("ui_left"):
		return 1.0
	if Input.is_action_pressed("ui_right"):
		return -1.0
	return 0.0

func _process(delta):
	DebugDraw.reset($Debug)
	
	# Orient the egg to be sitting on the wall and looking forward at all times
	var target = global_transform.origin + (global_transform.origin - prev_pos).normalized()
	if global_transform.origin == prev_pos:
		target = global_transform.origin - global_transform.basis.z.normalized()
	var surface_normal = get_floor_normal()
	look_at(target, surface_normal)
	prev_pos = global_transform.origin
	
	# Apply lean
	var dir = lean_dir()
	if dir != 0:
		lean_angle += dir * lean_speed * delta
		
		var weight = min(abs(lean_angle) / fall_angle, 1.0)
		spin_speed = lerp(0.0, spin_max_speed, weight)
		Util.music_speed_scale = lerp(1.0, 2.0, spin_speed / spin_max_speed)
	
	$Body.rotation = Vector3.ZERO
	$Body.rotate_object_local($Body.transform.basis.z, lean_angle)
	
	# Apply spin
	$Body/DancePivot.rotate_object_local($Body/DancePivot.transform.basis.y, sign(lean_angle) * spin_speed)
	
	# Displacement
	var offset = lean_angle / fall_angle
	global_transform.origin += lerp(Vector3.ZERO, -global_transform.basis.x*0.4, offset)
	
	if abs(lean_angle) > fall_angle:
		print("YOU LOSE")
	
	#velocity = Vector3.RIGHT * speed
	#velocity += -surface_normal * gravity
	#var collision = move_and_collide(velocity * delta)
	#if collision:
	#	velocity = velocity.slide(collision.normal)

# Get the surface normal of w/e is beneath us. This is used as the up vector for move_and_slide() to prevent the extra sliding!
func get_floor_normal():
	var from = global_transform.origin + global_transform.basis.y.normalized()
	var to = global_transform.origin + (-global_transform.basis.y.normalized() * 5)
	
	DebugDraw.global_line($Debug, from, to)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		#print("beneath me: ", result.normal)
		return result.normal
	return global_transform.basis.y.normalized()
