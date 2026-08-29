extends CanvasLayer

# its kind of cheap but as long it works thats what matters !

@onready var camera: Camera3D = get_tree().get_first_node_in_group("player_camera")
@onready var overlay: ColorRect = $ColorRect

@export var water_height: float = 0.0
@export var fade_speed: float = 4.0

var target_alpha: float = 0.0

func _process(delta):
	if camera == null:
		return

	if camera.global_position.y < water_height:
		target_alpha = 0.35
	else:
		target_alpha = 0.0

	var color = overlay.color
	color.a = move_toward(color.a, target_alpha, fade_speed * delta)
	overlay.color = color
