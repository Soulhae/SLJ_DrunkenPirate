extends State
class_name BossDive

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var boss_mesh: MeshInstance3D = $"../../Body"
@onready var dive_area: Area3D = $"../../BOX/DIVE"

@export var dive_speed: float = 40.0
@export var dive_depth: float = 1.5
@export var dive_damage: int = 10
@export var throw_force: float = 5.0
@export var stop_distance: float = 1.5

var diving := false
var player_hit := false


func enter() -> void:
	diving = true
	player_hit = false

	if not is_inside_tree():
		return

	dive_area.monitoring = false
	enemy.velocity = Vector3.ZERO

	# Face the player before starting the dive.
	if player == null or not player.is_inside_tree():
		return

	var direction = player.global_position - enemy.global_position
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

	# Make sure everything still exists after the wait.
	if not is_inside_tree():
		return

	if not enemy.is_inside_tree():
		return

	if player == null or not player.is_inside_tree():
		return

	if boss_mesh == null or not boss_mesh.is_inside_tree():
		return

	if dive_area == null or not dive_area.is_inside_tree():
		return


	# Stop before going underwater.
	enemy.velocity = Vector3.ZERO

	# Save the player's position.
	var target = player.global_position

	# Move the boss body underwater.
	boss_mesh.position.y = -dive_depth

	print("UNDERWATER")

	await get_tree().create_timer(0.25).timeout

	# Check again after underwater wait.
	if not is_inside_tree():
		return

	if not enemy.is_inside_tree():
		return

	if player == null or not player.is_inside_tree():
		return

	if boss_mesh == null or not boss_mesh.is_inside_tree():
		return

	if dive_area == null or not dive_area.is_inside_tree():
		return


	print("DIVE DASH")

	var direction = target - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	enemy.velocity = direction * dive_speed

	# Turn on hitbox only during the dash.
	dive_area.monitoring = true

	var dash_time := 1.0
	var elapsed := 0.0


	# ========================================================
	# DIVE DASH
	# ========================================================

	while elapsed < dash_time:

		if not is_inside_tree():
			return

		if not enemy.is_inside_tree():
			return

		if player == null or not player.is_inside_tree():
			break

		if dive_area == null or not dive_area.is_inside_tree():
			break

		elapsed += get_process_delta_time()


		# Stop when close to the player's current position.
		if enemy.global_position.distance_to(
			player.global_position
		) <= stop_distance:
			break


		# Check for player hit.
		if not player_hit:

			for body in dive_area.get_overlapping_bodies():

				if body.is_in_group("player"):

					player_hit = true

					body.take_damage(dive_damage)

					var throw_direction = (
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


		await get_tree().process_frame

		# Important: check after process-frame await.
		if not is_inside_tree():
			return


	# ========================================================
	# END DIVE
	# ========================================================

	if not is_inside_tree():
		return

	if enemy.is_inside_tree():
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

	if not enemy.is_inside_tree():
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
