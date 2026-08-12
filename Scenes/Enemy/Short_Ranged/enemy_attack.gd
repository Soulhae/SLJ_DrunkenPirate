extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name EnemyAttack

# References to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

# Attack cooldown.
var attack_cooldown = 1.0
var attack_timer = 0.0

func process(delta: float):
	# Return to chase if player leaves attack range.
	var distance = enemy.global_position.distance_to(player.global_position)

	if distance > enemy.AttackReach:
		Transitioned.emit(self, "enemychase")
		return

	# Deal damage after cooldown.
	attack_timer -= delta

	if attack_timer <= 0.0:
		print("Damage done")
		attack_timer = attack_cooldown

func enter():
	# Runs when entering the attack state.
	print("Attack! Distance: ", enemy.global_position.distance_to(player.global_position))

func physics_process(delta: float):
	# Face the player.
	var direction = (player.global_position - enemy.global_position).normalized()

	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(direction.x, 0, direction.z),
			Vector3.UP
		)

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
