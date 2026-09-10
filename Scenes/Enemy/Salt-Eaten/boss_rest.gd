extends State
class_name BossRest

var rest_time: float = 0.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"


func enter():
	rest_time = randf_range(2.0, 4.0)
	animation_player.stop()
	enemy.velocity = Vector3.ZERO


func process(delta: float):

	if enemy.global_position.distance_to(player.global_position) < enemy.ChaseDistance:
		Transitioned.emit(self, "bosschase")
		return

	rest_time -= delta

	if rest_time <= 0.0:
		Transitioned.emit(self, "bosswander")


func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
