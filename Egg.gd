extends Spatial

func _process(delta):
	rotate_y(0.01)
	rotate_x(0.001)
	
	# Cast grid of rays out it's butt to find the surface normal it's sitting on
	
	# Average the surface normal of every ray hit
	
	# Discard any ray hit that is greater than 90 deg from casting ray

	# Average normal reflected is direction of gravity
