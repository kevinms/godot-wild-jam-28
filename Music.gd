extends Spatial

onready var streams = [$Layer1, $Layer2, $Layer3, $Layer4, $Layer5]

var next_toggle: float

onready var test_track = [
	"res://music/test track/Track_1.ogg",
	"res://music/test track/Track_2.ogg",
	"res://music/test track/Track_3.ogg",
	"res://music/test track/Track_4.ogg",
	"res://music/test track/Track_5.ogg"
]

onready var sitting_pro = [
	"res://music/sitting pro/Track_1.ogg",
	"res://music/sitting pro/Track_2.ogg",
	"res://music/sitting pro/Track_3.ogg",
	"res://music/sitting pro/Track_4.ogg",
	"res://music/sitting pro/Track_5.ogg"
]

onready var this_egg_moves = [
	"res://music/this egg moves/Track_1.ogg",
	"res://music/this egg moves/Track_2.ogg",
	"res://music/this egg moves/Track_3.ogg",
	"res://music/this egg moves/Track_4.ogg",
	"res://music/this egg moves/Track_5.ogg"
]

onready var ost = [test_track, sitting_pro, this_egg_moves]

func _ready():
	randomize()
	
	var track = ost[rand_range(0, len(ost))]
	
	for i in range(len(track)):
		print("resource: ", track[i])
		var audio_stream = load(track[i])
		
		print("loaded: ", audio_stream)
		streams[i].stream = audio_stream
		streams[i].play()
		streams[i].volume_db = -80.0
	
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
