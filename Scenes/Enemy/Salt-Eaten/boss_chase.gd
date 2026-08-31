extends State
class_name BossChase

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

func process(_delta: float):

	var distance = enemy.global_position.distance_to(player.global_position)

	if distance > enemy.ChaseDistance:
		Transitioned.emit(self, "bosswander")
		return

	if distance <= enemy.DiveReach:
		Transitioned.emit(self, "bossattack")


func physics_process(delta: float):

	var direction = (
		player.global_position - enemy.global_position
	)

	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

	enemy.velocity.x = direction.x * enemy.RunSpeed
	enemy.velocity.z = direction.z * enemy.RunSpeed

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
