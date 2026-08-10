extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name EnemyWander

var wander_direction: Vector3
var wander_time: float = 0.0

# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()


# Choose a random direction and time.
func randomise_variables():
	if randf_range(0,3) != 1:
		wander_direction = Vector3(randf_range(-1.0, 1.0),0.0,randf_range(-1.0, 1.0)).normalized()
	else:
		wander_direction = Vector3.ZERO

	wander_time = randf_range(1.5, 4.0)


# Set up wandering.
func enter():
	randomise_variables()


# Check timers and chase distance.
func process(delta: float):
	wander_time -= delta

	if wander_time < 0.0:
		randomise_variables()

	if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
		Transitioned.emit(self, "enemychase")


# Move and face the random direction.
func physics_process(delta: float):

	# Face movement direction.
	if wander_direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(wander_direction.x, 0, wander_direction.z),
			Vector3.UP
		)

	# Move in the random direction.
	enemy.velocity.x = wander_direction.x * enemy.WalkSpeed
	enemy.velocity.z = wander_direction.z * enemy.WalkSpeed

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
