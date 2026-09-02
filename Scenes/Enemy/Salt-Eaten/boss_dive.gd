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

var diving := false
var player_hit := false

func enter():
	diving = true
	player_hit = false
	dive_area.monitoring = false
	enemy.velocity = Vector3.ZERO

	# Face the player before starting the dive.
	var direction = player.global_position - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()
		enemy.look_at(enemy.global_position + direction, Vector3.UP)

	dive()

func dive():
	print("DIVE WIND UP")

	await get_tree().create_timer(0.5).timeout

	enemy.velocity = Vector3.ZERO
	var target = player.global_position

	boss_mesh.position.y = -dive_depth

	print("UNDERWATER")

	await get_tree().create_timer(0.25).timeout

	print("DIVE DASH")

	var direction = target - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

	enemy.velocity = direction * dive_speed

	# Turn on hitbox only during the dash.
	dive_area.monitoring = true

	var dash_time := 1.0
	var elapsed := 0.0

	while elapsed < dash_time:
		elapsed += get_process_delta_time()

		# Stop when the boss gets close to the player.
		if enemy.global_position.distance_to(player.global_position) <= stop_distance:
			break

		if not player_hit:
			for body in dive_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					player_hit = true

					body.take_damage(dive_damage)

					var throw_direction = body.global_position - enemy.global_position
					throw_direction.y = 0.0

					if throw_direction.length() > 0.1:
						throw_direction = throw_direction.normalized()

					body.velocity = Vector3(
						throw_direction.x * 5.0,
						throw_force,
						throw_direction.z * 5.0
					)

					print("PLAYER HIT BY DIVE")
					break

		await get_tree().process_frame

	# End dash.
	dive_area.monitoring = false
	enemy.velocity = Vector3.ZERO
	boss_mesh.position.y = 0.0

	print("DIVE RECOVERY")

	await get_tree().create_timer(0.6).timeout

	diving = false

	print("DIVE FINISHED")

	Transitioned.emit(self, "bossrecovery")

func physics_process(delta):
	if diving:
		enemy.move_and_slide()
		return

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()

func exit():
	diving = false
	player_hit = false
	dive_area.monitoring = false
	enemy.velocity = Vector3.ZERO
	boss_mesh.position.y = 0.0
