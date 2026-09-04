extends State
class_name EnemyWander

var wander_direction: Vector3
var wander_time: float = 0.0

@onready var enemy: CharacterBody3D = get_owner()


func randomise_variables():
	if randf_range(0, 3) != 1:
		wander_direction = Vector3(
			randf_range(-1.0, 1.0),
			0.0,
			randf_range(-1.0, 1.0)
		).normalized()
	else:
		wander_direction = Vector3.ZERO

	wander_time = randf_range(1.5, 4.0)


func enter():
	randomise_variables()


func process(delta: float):
	wander_time -= delta

	if wander_time < 0.0:
		randomise_variables()

	var player = get_tree().get_first_node_in_group("player")

	if player != null:
		if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
			Transitioned.emit(self, "enemychase")


func physics_process(delta: float):
	if wander_direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(wander_direction.x, 0, wander_direction.z),
			Vector3.UP
		)

	enemy.velocity.x = wander_direction.x * enemy.WalkSpeed
	enemy.velocity.z = wander_direction.z * enemy.WalkSpeed

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
