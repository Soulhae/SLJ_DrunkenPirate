extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossWander

var wander_direction: Vector3
var wander_time: float = 0.0

# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()


# Choose a random direction and time.
func randomise_variables():
	if randi_range(0, 2) != 1:
		wander_direction = Vector3(
			randf_range(-1.0, 1.0),
			0.0,
			randf_range(-1.0, 1.0)
		).normalized()
	else:
		wander_direction = Vector3.ZERO

	wander_time = randf_range(1.5, 4.0)


# Set up wandering.
func enter():
	randomise_variables()


# Check timer and chase distance.
func process(delta: float):
	wander_time -= delta

	# Player is close enough to chase.
	if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
		Transitioned.emit(self, "bosschase")
		return

	# Finished wandering.
	if wander_time <= 0.0:
		Transitioned.emit(self, "bossrest")


# Move and face the random direction.
func physics_process(delta: float):

	if wander_direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + wander_direction,
			Vector3.UP
		)

	enemy.velocity.x = wander_direction.x * enemy.WalkSpeed
	enemy.velocity.z = wander_direction.z * enemy.WalkSpeed

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
