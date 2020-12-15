extends Node

# Blender
#   x: -left/+right
#   y: +forward/-back 
#   z: -down/+up
# Godot
#   x: -left/+right
#   y: -down/+up
#   z: -forward/+back
func tovec(x, y, z):
	return Vector3(float(x), float(z), -float(y))

func CurveFromCsvFile(res) -> Curve3D:
	var file = File.new()
	file.open(res, file.READ)
	
	var curve = Curve3D.new()
	curve.up_vector_enabled = true
	
	var i = 0
	while !file.eof_reached():
		var l = file.get_csv_line()
		if l.size() != 10:
			continue
		var co = tovec(l[0], l[1], l[2])
		var handle_left = tovec(l[3], l[4], l[5])
		var handle_right = tovec(l[6], l[7], l[8])
		var tilt = float(l[9])
		
		print(co, handle_left, handle_right, tilt)

		curve.add_point(co, handle_left, handle_right)
		curve.set_point_tilt(i, tilt)
		i += 1

	return curve
