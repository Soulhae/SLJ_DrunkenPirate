extends State
class_name SaltCloneAttack

@onready var clone: CharacterBody3D = get_owner()
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var attack_area: Area3D = $"../../AttackArea"

@export var attack_damage: int = 15
@export var attack_range: float = 1.5
@export var attack_windup: float = 0.4
@export var attack_duration: float = 0.2

var timer := 0.0
var attack_finished := false
var attack_active := false
var player_hit := false


func enter() -> void:
	attack_finished = false
	attack_active = false
	player_hit = false

	timer = attack_windup

	clone.velocity.x = 0.0
	clone.velocity.z = 0.0

	attack_area.monitoring = false

	print("SALT CLONE ATTACK")


func process(delta: float) -> void:
	if player == null:
		return

	# Face the player.
	var direction = player.global_position - clone.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		clone.look_at(
			clone.global_position + direction,
			Vector3.UP
		)


	# ========================================================
	# WIND UP
	# ========================================================

	if not attack_active:

		timer -= delta

		if timer <= 0.0:
			perform_attack()


	# ========================================================
	# ATTACK FINISHED
	# ========================================================

	elif attack_finished:

		attack_active = false
	attack_area.monitoring = false

	Transitioned.emit(
		self,
		"saltclonerecovery"
	)


func perform_attack() -> void:
	attack_active = true
	player_hit = false

	attack_area.monitoring = true

	print("SALT CLONE HIT")


	await get_tree().create_timer(attack_duration).timeout

	if not is_inside_tree():
		return

	attack_area.monitoring = false
	attack_finished = true


func physics_process(delta: float) -> void:

	clone.velocity.x = 0.0
	clone.velocity.z = 0.0

	if not clone.is_on_floor():
		clone.velocity += clone.get_gravity() * delta

	clone.move_and_slide()


	# ========================================================
	# DAMAGE
	# ========================================================

	if attack_active and not player_hit:

		for body in attack_area.get_overlapping_bodies():

			if body.is_in_group("player"):

				body.take_damage(attack_damage)

				player_hit = true

				print("PLAYER HIT BY SALT CLONE")

				break


func exit() -> void:

	attack_area.monitoring = false
	attack_active = false

	clone.velocity.x = 0.0
	clone.velocity.z = 0.0
