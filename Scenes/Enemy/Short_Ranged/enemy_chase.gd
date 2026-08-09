extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name EnemyChase

@onready var enemy: CharacterBody3D = get_owner()

func _physics_process(delta: float):
	var next_location = enemy.nav.get_next_path_position()
	var current_location = enemy.global_position

	var direction = (next_location - current_location).normalized()

	enemy.velocity = direction * enemy.RunSpeed

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta
