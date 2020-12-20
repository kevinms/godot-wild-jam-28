extends RigidBody

var speed = 3.0
var gravity = 2.0
var velocity: Vector3

var spin_max_speed = 0.2
var lean_speed = 2.0
var fall_angle = PI/2.4

var prev_pos: Vector3
var lean_angle: float
var spin_speed: float

var path_speed: float = 10.0
var path_speed_scale: float = 1.0

var user_lean_angle: float

var disable_egg: bool

var curve: Curve3D
var t: float

func set_curve(new_curve, new_t):
	curve = new_curve
	t = new_t

func _ready():
	prev_pos = global_transform.origin

func lean_dir() -> float:
	if Input.is_action_pressed("ui_left"):
		return 1.0
	if Input.is_action_pressed("ui_right"):
		return -1.0
	return 0.0

func path_surface_normal() -> Vector3:
	return curve.interpolate_baked_up_vector(t, true)

func calc_path_curvature() -> float:
	var offset = 1.0
	
	var spot = t
	
	# Current forward vector
	var forward: Vector3= -global_transform.basis.z.normalized()
	var plane = Plane(-global_transform.basis.x, global_transform.basis.x, global_transform.basis.z)
	
	# Next forward vector
	var p1 = curve.interpolate_baked(spot, false)
	var p2 = curve.interpolate_baked(spot+offset, false)
	var v1 = p2 - p1;
	
	v1 = plane.project(v1)
	
	DebugDraw.global_sphere($Debug, global_transform.origin + forward, Color.red, 0.2)
	DebugDraw.global_sphere($Debug, global_transform.origin + v1, Color.blue, 0.2)
	
	var angle = forward.angle_to(v1)
	
	# Determine if curve is bending left or right
	# Angle between the basis.x and v1
	if global_transform.basis.x.angle_to(v1) < PI/2:
		angle *= -1.0
	
	return angle

func fall_simulation():
	$DancePivot.rotate_object_local($DancePivot.transform.basis.y, sign(lean_angle) * spin_speed)

func _physics_process(delta):
	DebugDraw.reset($Debug)
	
	if disable_egg:
		fall_simulation()
		return
	
	var speed = path_speed * path_speed_scale
	if $FallTimer.is_stopped():
		$FallTimer.wait_time = 0.2 * path_speed_scale
	
	# Position on path
	t += min((delta * speed), curve.get_baked_length())
	var position = curve.interpolate_baked(t, false)
	global_transform.origin = position
	
	# Orient the egg to be sitting on the wall and looking forward at all times
	var target = global_transform.origin + (global_transform.origin - prev_pos).normalized()
	if global_transform.origin == prev_pos:
		target = global_transform.origin - global_transform.basis.z.normalized()
	#var surface_normal = get_floor_normal()
	var surface_normal = curve.interpolate_baked_up_vector(t, false)
	look_at(target, surface_normal)
	
	# Calc velocity
	velocity = (1.0/delta) * (global_transform.origin - prev_pos)
	prev_pos = global_transform.origin
	
	# Calculate lean
	var path_curvature = calc_path_curvature()
	#print("path curvature: ", path_curvature)
	
	# Directly set lean based on path curvature
	# The user must hold left or right to stay on the wall
	#lean_angle += path_curvature * 10.0 * delta
	lean_angle = -path_curvature * 10.0
	lean_angle = clamp(lean_angle, -fall_angle, fall_angle)
	
	if abs(lean_angle) >= fall_angle*.9:
		$WarningSign.visible = true
	else:
		$WarningSign.visible = false
	
	#TODO: adjust fall timer inverse to the path speed
	
#	var input_dir = lean_dir()
#	if input_dir < 0:
#		lean_angle -= fall_angle * 0.3
#	elif input_dir > 0:
#		lean_angle += fall_angle * 0.3
	
	apply_user_lean(delta)
	
	lean_angle = clamp(lean_angle, -fall_angle, fall_angle)
	
	var weight = min(abs(lean_angle) / fall_angle, 1.0)
	spin_speed = lerp(0.0, spin_max_speed, weight)
	Util.music_speed_scale = lerp(1.0, 2.0, spin_speed / spin_max_speed)
	
	# Displacement
	var offset = lean_angle / fall_angle
	global_transform.origin += lerp(Vector3.ZERO, -global_transform.basis.x*0.4, offset)
	
	# Lean
	rotate(global_transform.basis.z.normalized(), lean_angle)
	
	# Apply spin
	$DancePivot.rotate_object_local($DancePivot.transform.basis.y, sign(lean_angle) * spin_speed)
	
	if abs(lean_angle)+0.00001 >= fall_angle and !user_compensation():
		if $FallTimer.is_stopped():
			$FallTimer.start()
	else:
		$FallTimer.stop()

func apply_user_lean(delta):
	var user_speed = 3.0
	
	var input_dir = lean_dir()
	if input_dir < 0:
		user_lean_angle -= delta * user_speed
	elif input_dir > 0:
		user_lean_angle += delta * user_speed
	else:
		if user_lean_angle < 3.0:
			user_lean_angle = 0
		else:
			user_lean_angle -= sign(user_lean_angle) * (delta * user_speed)
	
	#var max_user_lean = fall_angle
	var max_user_lean = fall_angle * 0.3
	
	user_lean_angle = clamp(user_lean_angle, -max_user_lean, max_user_lean)
	
	lean_angle += user_lean_angle

func user_compensation() -> bool:
	var input_dir = lean_dir()
	
	if input_dir < 0.0 and -lean_angle < 0.0:
		return true
	if input_dir > 0.0 and -lean_angle > 0.0:
		return true
	return false

# Get the surface normal of w/e is beneath us. This is used as the up vector for move_and_slide() to prevent the extra sliding!
func get_floor_normal():
	var from = global_transform.origin + global_transform.basis.y.normalized()
	var to = global_transform.origin + (-global_transform.basis.y.normalized() * 5)
	
	#DebugDraw.global_line($Debug, from, to)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		#print("beneath me: ", result.normal)
		return result.normal
	return global_transform.basis.y.normalized()


func _on_FallTimer_timeout():
	print("YOU LOSE")
	disable_egg = true
	
	# Apply impulse
	print(velocity)
	apply_central_impulse(velocity)
	
	$DeathTimer.start()


func _on_DeathTimer_timeout():
	Global.game_over = true
