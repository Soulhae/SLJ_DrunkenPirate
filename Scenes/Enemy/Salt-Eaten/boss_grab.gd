extends State
class_name BossGrab

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var grab_area: Area3D = $"../../BOX/GRAB"

@export var grab_damage: int = 10
@export var throw_force: float = 100.0
@export var throw_up: float = 10.0

var finished: bool = false
var grabbed: bool = false


func enter():
	finished = false
	grabbed = false
	enemy.velocity = Vector3.ZERO
	grab()


func grab():

	print("GRAB WIND UP")

	grab_area.monitoring = false

	var main_loop = Engine.get_main_loop()
	if main_loop == null:
		return

	await main_loop.create_timer(0.6).timeout

	if not is_inside_tree():
		return

	print("GRAB")

	grab_area.monitoring = true

	main_loop = Engine.get_main_loop()
	if main_loop == null:
		return

	await main_loop.create_timer(0.1).timeout

	if not is_inside_tree():
		return

	for body in grab_area.get_overlapping_bodies():

		if body.is_in_group("player"):

			grabbed = true
			grab_area.monitoring = false

			print("PLAYER GRABBED")

			body.velocity = Vector3.ZERO

			main_loop = Engine.get_main_loop()
			if main_loop == null:
				return

			await main_loop.create_timer(0.5).timeout

			if not is_inside_tree():
				return

			body.take_damage(grab_damage, enemy)

			var direction: Vector3 = body.global_position - enemy.global_position
			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()
			else:
				direction = Vector3.ZERO

			body.velocity = Vector3(
				direction.x * throw_force,
				throw_up,
				direction.z * throw_force
			)

			print("PLAYER THROWN")

			break

	grab_area.monitoring = false

	main_loop = Engine.get_main_loop()
	if main_loop == null:
		return

	await main_loop.create_timer(0.8).timeout

	if not is_inside_tree():
		return

	finished = true


func process(_delta):

	if finished:
		finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta):

	# Always face the player during Grab.
	if player != null and player.is_inside_tree():

		var direction: Vector3 = player.global_position - enemy.global_position
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
