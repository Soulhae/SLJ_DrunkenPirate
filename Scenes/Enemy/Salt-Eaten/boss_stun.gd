extends State
class_name BossStun

@onready var enemy: CharacterBody3D = get_owner()
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"

@export var stun_time: float = 2.0


func enter() -> void:
	animation_player.stop()
	enemy.velocity = Vector3.ZERO

	print("========== BOSS STUNNED ==========")

	stun()


func stun() -> void:
	await get_tree().create_timer(stun_time).timeout

	if not is_inside_tree():
		return

	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:
	enemy.velocity = Vector3.ZERO

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	enemy.velocity = Vector3.ZERO
