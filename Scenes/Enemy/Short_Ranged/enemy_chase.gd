extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name EnemyChase

# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()


# Check if the player is too far away.
func process(delta: float):
	if enemy.global_position.distance_to(player.global_position) > enemy.ChaseDistance:
		Transitioned.emit(self, "enemywander")


# Move and face the player.
func physics_process(delta: float):
	var next_location = enemy.nav.get_next_path_position()
	var current_location = enemy.global_position

	# Get direction from the navigation path.
	var direction = (next_location - current_location).normalized()

	# Face the direction of movement.
	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(direction.x, 0, direction.z),
			Vector3.UP
		)
		
	# Move toward the player.
	enemy.velocity.x = direction.x * enemy.RunSpeed
	enemy.velocity.z = direction.z * enemy.RunSpeed

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
