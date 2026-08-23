extends "res://Scripts/StateMachine/state.gd"
class_name EnemyRecovery

@onready var enemy: CharacterBody3D = get_owner()

var recovery_time: float = 0.8


func enter() -> void:
	recovery_time = 0.8


func process(delta: float) -> void:
	recovery_time -= delta

	if recovery_time <= 0.0:
		Transitioned.emit(self, "enemychase")


func physics_process(delta: float) -> void:
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
