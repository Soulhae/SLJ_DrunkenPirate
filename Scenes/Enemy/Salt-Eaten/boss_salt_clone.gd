extends State
class_name BossSaltClone

@onready var enemy: CharacterBody3D = get_owner()
@onready var clone_spawn: Marker3D = $"../../BOX/SaltCloneSpawn"

@export var clone_scene: PackedScene
@export var recovery_time: float = 0.8

var attack_finished := false


func enter() -> void:

	attack_finished = false
	enemy.velocity = Vector3.ZERO

	summon_clone()


func summon_clone() -> void:

	print("SALT CLONE WIND UP")

	await get_tree().create_timer(0.6).timeout


	# ========================================================
	# CREATE CLONE
	# ========================================================

	if clone_scene == null:

		print("ERROR: SALT CLONE SCENE NOT ASSIGNED")

		attack_finished = true
		return


	var clone = clone_scene.instantiate()

	get_tree().current_scene.add_child(clone)

	clone.global_position = clone_spawn.global_position

	print("SALT CLONE CREATED")


	# ========================================================
	# BOSS RECOVERY
	# ========================================================

	await get_tree().create_timer(
		recovery_time
	).timeout

	print("SALT CLONE FINISHED")

	attack_finished = true


func process(_delta: float) -> void:

	if attack_finished:

		attack_finished = false

		Transitioned.emit(
			self,
			"bossrecovery"
		)


func physics_process(delta: float) -> void:

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():

		enemy.velocity += (
			enemy.get_gravity() *
			delta
		)

	enemy.move_and_slide()


func exit() -> void:

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
