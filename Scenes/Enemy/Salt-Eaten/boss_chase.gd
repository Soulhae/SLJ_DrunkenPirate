extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossChase

# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()


# Check if the player is too far away or close enough to attack.
func process(_delta: float):

	var distance_to_player = enemy.global_position.distance_to(
		player.global_position
	)

	# Player is too far away.
	if distance_to_player > enemy.ChaseDistance:
		Transitioned.emit(self, "bosswander")
		return

	# Player is close enough to attack.
	if distance_to_player <= enemy.AttackReach:
		Transitioned.emit(self, "bossattack")


# Move and face the player.
func physics_process(delta: float):

	var direction = (
		player.global_position - enemy.global_position
	).normalized()

	# Ignore vertical movement.
	direction.y = 0.0
	direction = direction.normalized()

	# Face the player.
	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	# Movement.
	enemy.velocity.x = direction.x * enemy.RunSpeed
	enemy.velocity.z = direction.z * enemy.RunSpeed

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()

	# Ignore vertical movement.
	direction.y = 0.0
	direction = direction.normalized()

	# Face the movement direction.
	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	# Movement.
	enemy.velocity.x = direction.x * enemy.RunSpeed
	enemy.velocity.z = direction.z * enemy.RunSpeed

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
