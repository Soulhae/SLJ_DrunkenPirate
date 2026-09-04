extends State
class_name BossDive

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var boss_mesh: MeshInstance3D = $"../../Body"
@onready var dive_area: Area3D = $"../../BOX/DIVE"

@export var dive_speed: float = 40.0
@export var dive_depth: float = 1.5
@export var dive_damage: int = 20
@export var throw_force: float = 5.0
@export var stop_distance: float = 1.5

var diving: bool = false
var player_hit: bool = false


func enter() -> void:
	diving = true
	player_hit = false

	if not is_inside_tree():
		return

	if dive_area != null:
		dive_area.monitoring = false

	enemy.velocity = Vector3.ZERO

	# Find player again in case the reference became invalid.
	player = get_tree().get_first_node_in_group("player")

	if player == null or not player.is_inside_tree():
		return

	# Face the player before starting the dive.
	var direction: Vector3 = player.global_position - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	dive()


func dive() -> void:
	print("DIVE WIND UP")

	await get_tree().create_timer(0.5).timeout

	# Make sure everything still exists.
	if not is_inside_tree():
		return

	if enemy == null or not enemy.is_inside_tree():
		return

	player = get_tree().get_first_node_in_group("player")

	if player == null or not player.is_inside_tree():
		return

	if boss_mesh == null or not boss_mesh.is_inside_tree():
		return

	if dive_area == null or not dive_area.is_inside_tree():
		return

	# Stop before going underwater.
	enemy.velocity = Vector3.ZERO

	# Save the player's position.
	var target: Vector3 = player.global_position

	# Move boss mesh underwater.
	boss_mesh.position.y = -dive_depth

	print("UNDERWATER")

	await get_tree().create_timer(0.25).timeout

	# Check again after underwater wait.
	if not is_inside_tree():
		return

	if enemy == null or not enemy.is_inside_tree():
		return

	player = get_tree().get_first_node_in_group("player")

	if player == null or not player.is_inside_tree():
		return

	if boss_mesh == null or not boss_mesh.is_inside_tree():
		return

	if dive_area == null or not dive_area.is_inside_tree():
		return

	print("DIVE DASH")

	# Dash toward the position where the player was.
	var direction: Vector3 = target - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	enemy.velocity = direction * dive_speed

	# Enable hitbox during dash.
	dive_area.monitoring = true

	var dash_time: float = 1.0
	var elapsed: float = 0.0

	# ========================================================
	# DIVE DASH
	# ========================================================

	while elapsed < dash_time:

		if not is_inside_tree():
			return

		if enemy == null or not enemy.is_inside_tree():
			return

		player = get_tree().get_first_node_in_group("player")

		if player == null or not player.is_inside_tree():
			break

		if dive_area == null or not dive_area.is_inside_tree():
			break

		elapsed += get_process_delta_time()

		# Stop when close to player's current position.
		if enemy.global_position.distance_to(
			player.global_position
		) <= stop_distance:
			break

		# Check for player hit.
		if not player_hit:

			for body in dive_area.get_overlapping_bodies():

				if body.is_in_group("player"):

					player_hit = true

					body.take_damage(dive_damage,enemy)

					var throw_direction: Vector3 = (
						body.global_position - enemy.global_position
					)

					throw_direction.y = 0.0

					if throw_direction.length() > 0.1:
						throw_direction = throw_direction.normalized()
					else:
						throw_direction = Vector3.ZERO

					body.velocity = Vector3(
						throw_direction.x * 5.0,
						throw_force,
						throw_direction.z * 5.0
					)

					print("PLAYER HIT BY DIVE")

					break

		# FIX:
		# Use Engine.get_main_loop() instead of get_tree()
		# so process_frame isn't accessed from a null SceneTree.
		var main_loop := Engine.get_main_loop()

		if main_loop == null:
			return

		await main_loop.process_frame

		if not is_inside_tree():
			return


	# ========================================================
	# END DIVE
	# ========================================================

	if not is_inside_tree():
		return

	if enemy != null and enemy.is_inside_tree():
		enemy.velocity = Vector3.ZERO

	if dive_area != null and dive_area.is_inside_tree():
		dive_area.monitoring = false

	if boss_mesh != null and boss_mesh.is_inside_tree():
		boss_mesh.position.y = 0.0

	print("DIVE RECOVERY")

	# Recovery.
	await get_tree().create_timer(0.6).timeout

	if not is_inside_tree():
		return

	if enemy == null or not enemy.is_inside_tree():
		return

	diving = false

	print("DIVE FINISHED")

	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:

	if not is_inside_tree():
		return

	if enemy == null or not enemy.is_inside_tree():
		return

	if diving:
		enemy.move_and_slide()
		return

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:

	diving = false
	player_hit = false

	if dive_area != null and dive_area.is_inside_tree():
		dive_area.monitoring = false

	if enemy != null and enemy.is_inside_tree():
		enemy.velocity = Vector3.ZERO

	if boss_mesh != null and boss_mesh.is_inside_tree():
		boss_mesh.position.y = 0.0
