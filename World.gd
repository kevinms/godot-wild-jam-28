extends Spatial

var curve: Curve3D

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
	Global.game_over = false
	curve = Util.CurveFromCsvFile("res://levels/curvature-test.txt")
	
	for i in curve.get_point_count():
		create_dot(curve.get_point_position(i), 0.4, Color.white.linear_interpolate(Color(0,0,1), float(i) / curve.get_point_count()))
		#create_dot(curve.get_point_in(i), 0.2, Color(1,0,0))
		#create_dot(curve.get_point_out(i), 0.2, Color(0,1,0))
	
	$Egg.set_curve(curve, 0.0)

func _process(delta):
	if Global.game_over:
		$GameOverOverlay.visible = true
		print("GAME OVER")

	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	#var position = curve.interpolate_baked($Egg.t * curve.get_baked_length(), false)
	
	var up = $Egg.path_surface_normal()
	var target = $Egg.global_transform.origin + (up * 2.0)
	var position = $Egg.global_transform.origin + (up * 3.0) + ($Egg.global_transform.basis.z * 5.0)
	$Camera.look_at_from_position(position, target, up)
