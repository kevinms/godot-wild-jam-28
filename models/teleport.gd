extends Spatial

var next_level = ""

func _on_Area_body_entered(body):
	Global.goto_scene(next_level)
