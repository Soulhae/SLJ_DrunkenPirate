extends State
class_name BossGroundSlam

@onready var enemy: CharacterBody3D = get_owner()
@onready var slam_radius: Area3D = $"../../BOX/slam_radius"

@export var slam_damage: int = 15
@export var boss_jump_force: float = 15.0
@export var player_launch_force: float = 10.0
@export var enemy_launch_force: float = 10.0
@export var knockback_force: float = 5.0

var attack_finished: bool = false


func enter():
	attack_finished = false
	slam_radius.monitoring = false
	ground_slam()


func ground_slam():

	if not enemy.is_on_floor():
		attack_finished = true
		return

	print("GROUND SLAM WIND UP")

	var main_loop = Engine.get_main_loop()
	if main_loop == null:
		return

	await get_tree().create_timer(0.8).timeout

	if not is_inside_tree():
		return

	enemy.velocity = Vector3.ZERO

	print("GROUND SLAM JUMP")

	enemy.velocity.y = boss_jump_force

	# Wait until the boss actually leaves the ground.
	while enemy.is_on_floor():

		if not is_inside_tree():
			return

		main_loop = Engine.get_main_loop()
		if main_loop == null:
			return

		await main_loop.process_frame


	# Wait until the boss lands.
	while not enemy.is_on_floor():

		if not is_inside_tree():
			return

		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

		main_loop = Engine.get_main_loop()
		if main_loop == null:
			return

		await main_loop.process_frame


	print("GROUND SLAM LAND")

	slam_radius.monitoring = true

	if not is_inside_tree():
		return

	await get_tree().create_timer(0.1).timeout

	if not is_inside_tree():
		return

	print("GROUND SLAM ATTACK")


	for body in slam_radius.get_overlapping_bodies():

		# ====================================================
		# PLAYER
		# ====================================================

		if body.is_in_group("player"):

			body.take_damage(slam_damage , enemy)

			var direction: Vector3 = body.global_position - enemy.global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()
			else:
				direction = Vector3.ZERO

			body.velocity = Vector3(
				direction.x * knockback_force,
				player_launch_force,
				direction.z * knockback_force
			)

			print("PLAYER LAUNCHED BY SLAM")


		# ====================================================
		# ENEMIES
		# ====================================================

		elif body.is_in_group("enemy"):

			# Don't launch the boss itself.
			if body == enemy:
				continue

			var direction: Vector3 = body.global_position - enemy.global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()
			else:
				direction = Vector3.ZERO

			body.velocity = Vector3(
				direction.x * knockback_force,
				enemy_launch_force,
				direction.z * knockback_force
			)

			print("ENEMY LAUNCHED BY SLAM")


	slam_radius.monitoring = false

	print("GROUND SLAM RECOVERY")

	await get_tree().create_timer(1.0).timeout

	if not is_inside_tree():
		return

	print("GROUND SLAM FINISHED")

	attack_finished = true


func process(_delta):
	if attack_finished:

		attack_finished = false

		Transitioned.emit(
			self,
			"bossrecovery"
		)


func physics_process(delta):

	# Don't interfere with the jump's horizontal movement.
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit():

	slam_radius.monitoring = false
