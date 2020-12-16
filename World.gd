extends Spatial

var curve: Curve3D
var t: float

func create_dot(pos, scale, color):
	var dot = MeshInstance.new()
	dot.mesh = SphereMesh.new()
	dot.global_transform.origin = pos
	dot.scale = Vector3.ONE * scale
	
	var mat = SpatialMaterial.new()
	mat.albedo_color = color
	dot.set_surface_material(0, mat)
	
	add_child(dot)

func _ready():
	t = 0.0
	curve = Util.CurveFromCsvFile("res://levels/loop.csv")
	
	for i in curve.get_point_count():
		create_dot(curve.get_point_position(i), 0.4, Color.white.linear_interpolate(Color(0,0,1), float(i) / curve.get_point_count()))
		#create_dot(curve.get_point_in(i), 0.2, Color(1,0,0))
		#create_dot(curve.get_point_out(i), 0.2, Color(0,1,0))

func _process(delta):
	t += (delta * 0.1)
	
	var position = curve.interpolate_baked(t * curve.get_baked_length(), false)
	$Egg.global_transform.origin = position
	
	print(t, " ", curve.get_baked_length(), " ", position)
