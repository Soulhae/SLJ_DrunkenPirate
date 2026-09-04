extends State
class_name BossStun

@onready var enemy: CharacterBody3D = get_owner()

@export var stun_time: float = 1.0

var stun_finished: bool = false


func enter() -> void:
	stun_finished = false
	enemy.velocity = Vector3.ZERO

	print("========== BOSS STUNNED ==========")

	stun()


func stun() -> void:
	await get_tree().create_timer(stun_time).timeout

	if not is_inside_tree():
		return

	stun_finished = true


func process(_delta: float) -> void:
	if stun_finished:
		stun_finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:
	enemy.velocity = Vector3.ZERO

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	enemy.velocity = Vector3.ZERO
