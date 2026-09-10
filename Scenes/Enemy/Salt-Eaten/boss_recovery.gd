extends State
class_name BossRecovery

@onready var enemy: CharacterBody3D = get_owner()
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"

@export var recovery_time: float = 0.8


func enter():
	animation_player.stop()
	enemy.velocity = Vector3.ZERO

	print(" ====================    RECOVERY   ======================== ")


func process(delta: float):
	recovery_time -= delta

	if recovery_time <= 0.0:
		Transitioned.emit(self, "bosschase")


func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
