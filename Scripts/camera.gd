extends Camera3D

var shake_time: float = 0.0
var shake_strength: float = 0.0

var original_rotation: Vector3


func _ready():
	original_rotation = rotation


func _process(delta):
	if shake_time > 0.0:
		shake_time -= delta

		var wobble_x = sin(shake_time * 35.0) * shake_strength
		var wobble_z = cos(shake_time * 30.0) * shake_strength

		rotation = original_rotation + Vector3(
			wobble_x,
			0.0,
			wobble_z
		)

	else:
		rotation = original_rotation


func shake(duration: float, strength: float):
	shake_time = duration
	shake_strength = strength
