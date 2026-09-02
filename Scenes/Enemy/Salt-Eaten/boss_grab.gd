extends State
class_name BossGrab

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var grab_area: Area3D = $"../../BOX/GRAB"

@export var grab_damage: int = 5
@export var throw_force: float = 100.0
@export var throw_up: float = 10.0

var finished := false
var grabbed := false


func enter():
	finished = false
	grabbed = false
	enemy.velocity = Vector3.ZERO
	grab()


func grab():

	print("GRAB WIND UP")

	grab_area.monitoring = false

	await get_tree().create_timer(0.6).timeout

	print("GRAB")

	grab_area.monitoring = true

	await get_tree().create_timer(0.1).timeout

	for body in grab_area.get_overlapping_bodies():

		if body.is_in_group("player"):

			grabbed = true
			grab_area.monitoring = false

			print("PLAYER GRABBED")

			body.velocity = Vector3.ZERO

			await get_tree().create_timer(0.5).timeout

			body.take_damage(grab_damage)

			var direction = body.global_position - enemy.global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()

			# Throw player far away.
			body.velocity = Vector3(
				direction.x * throw_force,
				throw_up,
				direction.z * throw_force
			)

			print("PLAYER THROWN")

			break

	grab_area.monitoring = false

	await get_tree().create_timer(0.8).timeout

	finished = true


func process(_delta):

	if finished:
		finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta):

	# Always face the player during Grab.
	if player != null:
		var direction = player.global_position - enemy.global_position
		direction.y = 0.0

		if direction.length() > 0.1:
			direction = direction.normalized()
			enemy.look_at(
				enemy.global_position + direction,
				Vector3.UP
			)

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit():

	grab_area.monitoring = false
	grabbed = false
	enemy.velocity = Vector3.ZERO
