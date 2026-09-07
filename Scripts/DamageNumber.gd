extends Node3D

@onready var label: Label3D = $Label3D

@export var text_color: Color = Color.WHITE
@export var lifetime: float = 0.7
@export var float_height: float = 0.8

var start_position: Vector3
var elapsed: float = 0.0


func _ready() -> void:
	label.modulate = text_color


func setup(damage: int) -> void:
	label.text = str(damage)
	start_position = global_position


func _process(delta: float) -> void:
	elapsed += delta

	var progress := elapsed / lifetime

	# Float upward
	global_position.y = start_position.y + float_height * progress

	# Fade out while keeping the chosen color
	var color := text_color
	color.a = 1.0 - progress
	label.modulate = color

	if elapsed >= lifetime:
		queue_free()
