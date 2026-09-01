extends State
class_name BossSaltBomb

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var bomb_spawn: Marker3D = $"../../BOX/SaltBombSpawn"

@export var bomb_scene: PackedScene

@export var wind_up_time: float = 0.7
@export var recovery_time: float = 1.0

var attack_finished := false
var attacking := false


func enter() -> void:

	attack_finished = false
	attacking = true

	enemy.velocity = Vector3.ZERO

	salt_bomb()


func salt_bomb() -> void:

	print("SALT BOMB WIND UP")

	# Face the player.
	var direction = (
		player.global_position -
		enemy.global_position
	)

	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	await get_tree().create_timer(
		wind_up_time
	).timeout


	# ========================================================
	# CREATE BOMB
	# ========================================================

	if bomb_scene == null:
		print("ERROR: SALT BOMB SCENE NOT ASSIGNED")
		attack_finished = true
		return

	var bomb = bomb_scene.instantiate()

	get_tree().current_scene.add_child(bomb)

	bomb.global_position = bomb_spawn.global_position


	# ========================================================
	# TARGET PLAYER'S CURRENT POSITION
	# ========================================================

	var target_position = player.global_position

	bomb.set_target(target_position)

	print("SALT BOMB THROW")


	# ========================================================
	# RECOVERY
	# ========================================================

	await get_tree().create_timer(
		recovery_time
	).timeout

	attacking = false

	print("SALT BOMB FINISHED")

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
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:

	attacking = false
