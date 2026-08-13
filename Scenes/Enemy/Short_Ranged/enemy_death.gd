extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name EnemyDeath
# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

func enter():
	print("Enemy Died")

	# Stop movement
	enemy.velocity = Vector3.ZERO

	# Disable collisions
	enemy.set_physics_process(false)

func process(delta: float):
	# Nothing for now
	pass

func physics_process(delta: float):
	# Nothing for now
	pass
