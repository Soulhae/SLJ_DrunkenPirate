extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossRest

var rest_time: float = 0.0

# Reference to the enemy.
@onready var enemy: CharacterBody3D = get_owner()


# Set up resting.
func enter():
	rest_time = randf_range(2.0, 4.0)


# Check rest timer.
func process(delta: float):
	rest_time -= delta

	if rest_time <= 0.0:
		Transitioned.emit(self, "bosswander")


# Keep the boss still.
func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
