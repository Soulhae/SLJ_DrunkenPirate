extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossRecovery

# Reference to the enemy.
@onready var enemy: CharacterBody3D = get_owner()

# How long the boss stays in recovery.
var recovery_time: float = 0.8


# Set up recovery.
func enter():
	print("RECOVERY")
	recovery_time = 0.8


# Check recovery timer.
func process(delta: float):
	recovery_time -= delta

	# Return to chasing when recovery is finished.
	if recovery_time <= 0.0:
		Transitioned.emit(self, "bosschase")


# Keep the boss still during recovery.
func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
