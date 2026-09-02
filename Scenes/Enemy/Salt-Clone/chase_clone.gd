extends State
class_name SaltCloneChase

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var clone: CharacterBody3D = get_owner()

@export var attack_range: float = 1.5


func enter() -> void:
	clone.velocity.x = 0.0
	clone.velocity.z = 0.0


func process(_delta: float) -> void:

	if player == null:
		return

	var distance = clone.global_position.distance_to(player.global_position)

	# Close enough to attack
	if distance <= attack_range:
		Transitioned.emit(self, "saltcloneattack")
		return


func physics_process(delta: float) -> void:

	if player == null:
		return

	var direction = player.global_position - clone.global_position
	direction.y = 0.0

	if direction.length() > 0.1:

		direction = direction.normalized()

		# Look at player
		clone.look_at(
			clone.global_position + direction,
			Vector3.UP
		)

		# Move toward player
		clone.velocity.x = direction.x * clone.move_speed
		clone.velocity.z = direction.z * clone.move_speed

	else:

		clone.velocity.x = 0.0
		clone.velocity.z = 0.0


	# Gravity
	if not clone.is_on_floor():
		clone.velocity += clone.get_gravity() * delta

	clone.move_and_slide()


func exit() -> void:
	clone.velocity.x = 0.0
	clone.velocity.z = 0.0
