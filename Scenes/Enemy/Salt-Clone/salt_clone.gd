extends CharacterBody3D
class_name SaltClone

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var attack_area: Area3D = $AttackArea

@export var move_speed: float = 5.0
@export var damage: int = 15
@export var lifetime: float = 5.0
@export var attack_cooldown: float = 1.0

var time_alive := 0.0
var can_attack := true


func _physics_process(delta: float) -> void:

	if player == null:
		return

	# ========================================================
	# LIFETIME
	# ========================================================

	time_alive += delta

	if time_alive >= lifetime:
		queue_free()
		return


	# ========================================================
	# CHASE PLAYER
	# ========================================================

	var direction = (
		player.global_position -
		global_position
	)

	direction.y = 0.0

	if direction.length() > 0.1:

		direction = direction.normalized()

		look_at(
			global_position + direction,
			Vector3.UP
		)

		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed

	else:

		velocity.x = 0.0
		velocity.z = 0.0


	# ========================================================
	# GRAVITY
	# ========================================================

	if not is_on_floor():
		velocity += get_gravity() * delta


	move_and_slide()


	# ========================================================
	# ATTACK
	# ========================================================

	if can_attack:

		for body in attack_area.get_overlapping_bodies():

			if body.is_in_group("player"):

				body.take_damage(damage)

				print("PLAYER HIT BY SALT CLONE")

				can_attack = false

				await get_tree().create_timer(
					attack_cooldown
				).timeout

				can_attack = true

				break
