extends KinematicBody

var speed = 3.0
var gravity = 2.0
var velocity: Vector3

var prev_pos: Vector3

func _ready():
	prev_pos = global_transform.origin

func _process(delta):
	DebugDraw.reset($Debug)
	
	# Silly spin
	$Body.rotate_y(0.1)
	
	# Orient the egg to be sitting on the wall and looking forward at all times
	var target = global_transform.origin + (global_transform.origin - prev_pos).normalized()
	var surface_normal = get_floor_normal()
	look_at(target, surface_normal)
	prev_pos = global_transform.origin
	
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
