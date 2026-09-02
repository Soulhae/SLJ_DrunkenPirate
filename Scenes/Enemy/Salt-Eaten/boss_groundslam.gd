extends "res://Scripts/StateMachine/state.gd"
class_name BossGroundSlam

@onready var enemy: CharacterBody3D = get_owner()
@onready var slam_radius: Area3D = $"../../BOX/slam_radius"

@export var slam_damage: int = 5
@export var boss_jump_force: float = 15.0
@export var player_launch_force: float = 10.0
@export var knockback_force: float = 5.0

var attack_finished := false


func enter():
	attack_finished = false
	slam_radius.monitoring = false
	ground_slam()


func ground_slam():

	if not enemy.is_on_floor():
		attack_finished = true
		return

	print("GROUND SLAM WIND UP")
	await get_tree().create_timer(0.8).timeout

	enemy.velocity = Vector3.ZERO

	print("GROUND SLAM JUMP")
	enemy.velocity.y = boss_jump_force

	# Wait until the boss actually leaves the ground.
	while enemy.is_on_floor():
		await get_tree().process_frame

	# Wait until the boss lands.
	while not enemy.is_on_floor():
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0
		await get_tree().process_frame

	print("GROUND SLAM LAND")

	slam_radius.monitoring = true
	await get_tree().create_timer(0.1).timeout

	print("GROUND SLAM ATTACK")

	for body in slam_radius.get_overlapping_bodies():

		if body.is_in_group("player"):

			body.take_damage(slam_damage)

			var direction = body.global_position - enemy.global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()

			body.velocity = Vector3(
				direction.x * knockback_force,
				player_launch_force,
				direction.z * knockback_force
			)

			print("PLAYER THROWN BY SLAM")

	slam_radius.monitoring = false

	print("GROUND SLAM RECOVERY")
	await get_tree().create_timer(1.0).timeout

	print("GROUND SLAM FINISHED")
	attack_finished = true


func process(_delta):
	if attack_finished:
		attack_finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta):

	# Don't interfere with the jump's horizontal movement.
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit():
	slam_radius.monitoring = false
