extends State
class_name BossDive

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var boss_mesh: Node3D = $"../../boss/Armature/Skeleton3D/Rapier"
@onready var dive_area: Area3D = $"../../BOX/DIVE"
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"
@onready var mesh: MeshInstance3D = $"../../boss/Armature/Skeleton3D/Rapier"

@export var dive_speed: float = 40.0
@export var dive_damage: int = 20
@export var throw_force: float = 5.0
@export var stop_distance: float = 1.5

var original_material: Material
var original_color: Color

var diving: bool = false
var player_hit: bool = false
var original_position: Vector3


func enter() -> void:
	enemy.velocity = Vector3.ZERO
	diving = false
	player_hit = false

	original_position = boss_mesh.position

	if not is_inside_tree():
		return

	if dive_area != null:
		dive_area.monitoring = false

	player = get_tree().get_first_node_in_group("player")

	if player == null or not player.is_inside_tree():
		return

	var direction: Vector3 = player.global_position - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	# Blue flash = DIVE
	flash_attack_color(Color(0.2, 0.5, 1.0))

	diving = true
	animation_player.play("swing")

	dive()

func dive() -> void:
	print("DIVE WIND UP")

	# Short wind-up
	await get_tree().create_timer(0.5).timeout

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

	# Stop before starting the dive
	enemy.velocity = Vector3.ZERO

	# Save player's position
	var target: Vector3 = player.global_position

	# Lower the boss mesh
	boss_mesh.position.y = original_position.y - 1.0

	print("DIVE LOWERED")

	# Very short extra pause
	await get_tree().create_timer(0.25).timeout

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

	# Dash toward where the player was
	var direction: Vector3 = target - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()
	else:
		direction = Vector3.ZERO

	enemy.velocity = direction * dive_speed

	# Enable hitbox
	dive_area.monitoring = true

	var dash_time: float = 1.0
	var elapsed: float = 0.0

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

		if enemy.global_position.distance_to(
			player.global_position
		) <= stop_distance:
			break

		if not player_hit:

			for body in dive_area.get_overlapping_bodies():

				if body.is_in_group("player"):

					player_hit = true

					var damage = dive_damage

					if enemy.phase_2_started:
						damage = 25

					body.take_damage(damage, enemy)

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

		var main_loop := Engine.get_main_loop()

		if main_loop == null:
			return

		await main_loop.process_frame

		if not is_inside_tree():
			return

	# END DIVE

	if not is_inside_tree():
		return

	if enemy != null and enemy.is_inside_tree():
		enemy.velocity = Vector3.ZERO

	if dive_area != null and dive_area.is_inside_tree():
		dive_area.monitoring = false

	# Restore mesh
	if boss_mesh != null and boss_mesh.is_inside_tree():
		boss_mesh.position = original_position

	print("DIVE RECOVERY")

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

	# Always restore original mesh position
	if boss_mesh != null and boss_mesh.is_inside_tree():
		boss_mesh.position = original_position

func flash_attack_color(color: Color) -> void:
	if mesh == null:
		return

	if mesh.material_override == null:
		original_material = mesh.get_active_material(0)

		if original_material == null:
			return

		var new_material = original_material.duplicate()
		mesh.material_override = new_material

	var material = mesh.material_override

	if material is StandardMaterial3D:
		original_color = material.albedo_color
		material.albedo_color = color

		await get_tree().create_timer(0.1).timeout

		if not is_inside_tree():
			return

		material.albedo_color = original_color
