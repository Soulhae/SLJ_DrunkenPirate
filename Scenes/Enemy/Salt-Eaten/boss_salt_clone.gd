extends State
class_name BossSaltClone

@onready var enemy: CharacterBody3D = get_owner()
@onready var clone_spawn: Marker3D = $"../../BOX/SaltCloneSpawn"
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"
@onready var clone_eff: GPUParticles3D = $"../../clone spawn"

@export var clone_scene: PackedScene
@export var recovery_time: float = 0.8


func enter() -> void:
	animation_player.play("punch")
	enemy.velocity = Vector3.ZERO

	summon_clone()


func summon_clone() -> void:

	print("SALT CLONE WIND UP")

	await get_tree().create_timer(0.6).timeout

	if not is_inside_tree():
		return

	if clone_scene == null:
		print("ERROR: SALT CLONE SCENE NOT ASSIGNED")
		Transitioned.emit(self, "bossrecovery")
		return

	var clone = clone_scene.instantiate()

	get_tree().current_scene.add_child(clone)
	clone.global_position = clone_spawn.global_position

	# PLAY CLONE SPAWN EFFECT
	if is_instance_valid(clone_eff):
		clone_eff.restart()
		clone_eff.emitting = true

	print("SALT CLONE CREATED")

	await get_tree().create_timer(recovery_time).timeout

	if not is_inside_tree():
		return

	print("SALT CLONE FINISHED")

	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
