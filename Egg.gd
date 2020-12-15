extends KinematicBody

var speed = 3.0
var gravity = 2.0
var velocity: Vector3

func _process(delta):
	#rotate_y(0.01)
	#rotate_x(0.001)
	
	# Cast grid of rays out it's butt to find the surface normal it's sitting on
	var surface_normal = get_floor_normal()
	
	# Average the surface normal of every ray hit
	# Discard any ray hit that is greater than 90 deg from casting ray
	# Average normal reflected is direction of gravity
	
	# Rotate the player so it's always pointing in the direction of the surface normal
	var xform = align_with_y(global_transform, surface_normal)
	global_transform = global_transform.interpolate_with(xform, 1.0)
	
	velocity = Vector3.RIGHT * speed
	velocity += -surface_normal * gravity
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		#jumping = false
		velocity = velocity.slide(collision.normal)


# Get the surface normal of w/e is beneath us. This is used as the up vector for move_and_slide() to prevent the extra sliding!
func get_floor_normal():
	var from = global_transform.origin
	var to = global_transform.origin + (-global_transform.basis.y.normalized() * 5)
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	
	if result:
		#print("beneath me: ", result.normal)
		return result.normal
	return global_transform.basis.y.normalized()

# https://kidscancode.org/godot_recipes/3d/3d_align_surface/
func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
