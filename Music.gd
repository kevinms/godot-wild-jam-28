extends Spatial

onready var streams = [$Layer1, $Layer2, $Layer3, $Layer4, $Layer5]

var next_toggle: float

func _ready():
	randomize()
	
	var stream: AudioStreamPlayer = streams[rand_range(0, len(streams))]
	stream.volume_db = 0.0

func _process(delta):
	next_toggle -= delta * Util.music_speed_scale
	
	for s in streams:
		s.pitch_scale = Util.music_speed_scale
	
	#music_speed_scale += 0.01
	
	if next_toggle <= 0:
		var stream: AudioStreamPlayer = streams[rand_range(0, len(streams))]
		
		if stream.volume_db < 0.0:
			stream.volume_db = 0.0
		else:
			stream.volume_db = -80.0
		
		#next_toggle = rand_range(1.0, 5.0)
		next_toggle = rand_range(5.0, 10.0)
