extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossChase

# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()


# Check if the player is too far away.
func process(_delta: float):
	if enemy.global_position.distance_to(player.global_position) > enemy.ChaseDistance:
		Transitioned.emit(self, "bosswander")
	elif enemy.global_position.distance_to(player.global_position) < enemy.AttackReach:
		#Transitioned.emit(self, "enemyattack")
		pass

# Move and face the player
func physics_process(delta: float):

	var direction = (
		player.global_position - enemy.global_position
	).normalized()

	# Face the player
	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(direction.x, 0, direction.z),
			Vector3.UP
		)

	# Movement
	enemy.velocity.x = direction.x * enemy.RunSpeed
	enemy.velocity.z = direction.z * enemy.RunSpeed

	# Gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
