extends State
class_name SaltCloneRecovery

@onready var clone: CharacterBody3D = get_owner()

@export var recovery_time: float = 1.5

var timer: float = 0.0


func enter() -> void:
	timer = recovery_time

	# Stop the clone completely during recovery
	clone.velocity.x = 0.0
	clone.velocity.z = 0.0


func process(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		Transitioned.emit(self, "saltclonechase")


func physics_process(delta: float) -> void:
	# Keep clone stationary
	clone.velocity.x = 0.0
	clone.velocity.z = 0.0

	# Gravity
	if not clone.is_on_floor():
		clone.velocity += clone.get_gravity() * delta

	clone.move_and_slide()


func exit() -> void:
	clone.velocity.x = 0.0
	clone.velocity.z = 0.0
