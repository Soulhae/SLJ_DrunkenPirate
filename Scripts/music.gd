extends Node

@onready var music_a: AudioStreamPlayer = $MUSICA
@onready var music_b: AudioStreamPlayer = $MUSICB

@export var crossfade_time := 2.0

var current: AudioStreamPlayer
var next: AudioStreamPlayer
var song_length: float


func _ready():
	current = music_a
	next = music_b

	song_length = current.stream.get_length()

	current.volume_db = 0.0
	next.volume_db = -80.0

	current.play()

	loop_music()


func loop_music():
	await get_tree().create_timer(song_length - crossfade_time).timeout

	next.play()

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		current,
		"volume_db",
		-80.0,
		crossfade_time
	)

	tween.tween_property(
		next,
		"volume_db",
		0.0,
		crossfade_time
	)

	await tween.finished

	current.stop()

	var temp = current
	current = next
	next = temp

	loop_music()
