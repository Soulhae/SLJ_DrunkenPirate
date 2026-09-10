extends State
class_name BossGroundSlam

@onready var enemy: CharacterBody3D = get_owner()
@onready var slam_radius: Area3D = $"../../BOX/slam_radius"
@onready var slam = $"../../slam"
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"
@onready var slam_impact: Node3D = $"../../Slam Impact"
@onready var animation: AnimationPlayer = $"../../Slam Impact/AnimationPlayer"

@export var slam_damage: int = 15
@export var boss_jump_force: float = 15.0
@export var player_launch_force: float = 10.0
@export var enemy_launch_force: float = 10.0
@export var knockback_force: float = 5.0
@export var wind_up_time: float = 0.8
@export var slam_recovery_time: float = 1.0


func enter() -> void:
	animation_player.play("slam")
	slam_radius.monitoring = false
	enemy.velocity = Vector3.ZERO

	ground_slam()


func ground_slam() -> void:

	if not is_inside_tree() or not is_instance_valid(enemy):
		return

	if not enemy.is_on_floor():
		Transitioned.emit(self, "bossrecovery")
		return

	print("GROUND SLAM WIND UP")

	var tree := get_tree()

	await tree.create_timer(wind_up_time).timeout

	if not is_inside_tree() or not is_instance_valid(enemy):
		return

	enemy.velocity = Vector3.ZERO

	print("GROUND SLAM JUMP")

	enemy.velocity.y = boss_jump_force


	# Wait until the boss leaves the ground.
	while enemy.is_on_floor():

		if not is_inside_tree() or not is_instance_valid(enemy):
			return

		await tree.process_frame


	# Wait until the boss lands.
	while not enemy.is_on_floor():

		if not is_inside_tree() or not is_instance_valid(enemy):
			return

		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

		await tree.process_frame


	if not is_inside_tree() or not is_instance_valid(enemy):
		return

	print("GROUND SLAM LAND")
	animation.play("dust")

	# Show the slam impact when the boss lands.
	slam_impact.visible = true

	# Restart and play the particle effect.
	for child in slam_impact.get_children():

		if child is GPUParticles3D:
			child.restart()
			child.emitting = true


	slam.play()

	slam_radius.monitoring = true

	await tree.create_timer(0.1).timeout

	if not is_inside_tree() or not is_instance_valid(enemy):
		return

	print("GROUND SLAM ATTACK")


	for body in slam_radius.get_overlapping_bodies():

		if not is_instance_valid(body):
			continue


		# PLAYER
		if body.is_in_group("player"):

			body.take_damage(slam_damage, enemy)

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


		# ENEMIES
		elif body.is_in_group("enemy"):

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


	# Let the particles play.
	await tree.create_timer(0.5).timeout

	if not is_inside_tree():
		return

	# Hide the slam impact again.
	slam_impact.visible = false


	print("GROUND SLAM RECOVERY")

	await tree.create_timer(slam_recovery_time).timeout

	if not is_inside_tree() or not is_instance_valid(enemy):
		return

	print("GROUND SLAM FINISHED")

	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:

	if not is_instance_valid(enemy):
		return

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:

	if is_instance_valid(slam_radius):
		slam_radius.monitoring = false

	if is_instance_valid(enemy):
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

	# Always hide the impact when leaving the state.
	if is_instance_valid(slam_impact):
		slam_impact.visible = false
