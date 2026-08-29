extends State
class_name BossAttack

# References
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

# Attack hitboxes
@onready var slam_radius: Area3D = $"../../BOX/slam_radius"
@onready var punch_hitbox: Area3D = $"../../BOX/punch_hitbox"


# Attack damage
@export var punch_damage: int = 20
@export var slam_damage: int = 30

# Attack state
var attack_finished: bool = false
var last_attack: int = -1
var ground_slam_active: bool = false


func enter() -> void:
	attack_finished = false
	ground_slam_active = false
	punch_hitbox.monitoring = false

	choose_attack()


# Choose which attack to use.
func choose_attack() -> void:

	var distance_to_player = enemy.global_position.distance_to(
		player.global_position
	)

	var possible_attacks: Array[int] = []
	var weights: Array[float] = []

	# Close range.
	if distance_to_player <= 4.0:
		possible_attacks = [0, 1]
		weights = [0.6, 0.4]

	# Mid / long range.
	else:
		possible_attacks = [0, 1]
		weights = [0.4, 0.6]

	# Prevent the same attack twice in a row.
	if possible_attacks.size() > 1 and last_attack in possible_attacks:
		var index = possible_attacks.find(last_attack)
		possible_attacks.remove_at(index)
		weights.remove_at(index)

	var attack = choose_weighted_attack(
		possible_attacks,
		weights
	)

	last_attack = attack

	match attack:
		0:
			punch()
		1:
			ground_slam()


# Choose an attack using weighted randomness.
func choose_weighted_attack(
	attacks: Array[int],
	weights: Array[float]
) -> int:

	var total_weight: float = 0.0

	for weight in weights:
		total_weight += weight

	var random_value = randf_range(
		0.0,
		total_weight
	)

	for i in range(attacks.size()):
		random_value -= weights[i]

		if random_value <= 0.0:
			return attacks[i]

	return attacks[attacks.size() - 1]


# PUNCH
func punch() -> void:

	print("PUNCH WIND UP")

	punch_hitbox.monitoring = false

	await get_tree().create_timer(0.6).timeout

	print("PUNCH ATTACK")

	punch_hitbox.monitoring = true

	await get_tree().create_timer(0.2).timeout

	for body in punch_hitbox.get_overlapping_bodies():

		if body.is_in_group("player"):
			body.take_damage(punch_damage)

			# Push the player in the direction the boss faces.
			var punch_direction = -enemy.global_transform.basis.z

			punch_direction.y = 0.0
			punch_direction = punch_direction.normalized()

			body.velocity.x = punch_direction.x * 8.0
			body.velocity.z = punch_direction.z * 8.0
			body.velocity.y = 3.0

			print("PLAYER PUNCHED")

	punch_hitbox.monitoring = false

	attack_finished = true


# GROUND SLAM
func ground_slam() -> void:

	# Ground Slam requires the boss to be grounded.
	if not enemy.is_on_floor():
		attack_finished = true
		return

	ground_slam_active = true

	print("GROUND SLAM WIND UP")

	await get_tree().create_timer(0.8).timeout

	# Remember where the boss started the jump.
	var slam_x = enemy.global_position.x
	var slam_z = enemy.global_position.z

	# Stop horizontal movement before jumping.
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	print("GROUND SLAM JUMP")

	enemy.velocity.y = 10.0

	await get_tree().create_timer(0.15).timeout

	# Keep the boss from moving horizontally while airborne.
	while not enemy.is_on_floor():

		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

		await get_tree().process_frame

	# Put the boss back at the original landing position.
	enemy.global_position.x = slam_x
	enemy.global_position.z = slam_z

	print("GROUND SLAM LAND")

	await get_tree().create_timer(0.1).timeout

	print("GROUND SLAM ATTACK")

	var bodies = slam_radius.get_overlapping_bodies()

	for body in bodies:

		# Player
		if body.is_in_group("player"):

			body.take_damage(slam_damage)

			var direction = (
				body.global_position
				- enemy.global_position
			)

			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()

			body.velocity.x = direction.x * 5.0
			body.velocity.z = direction.z * 5.0
			body.velocity.y = 10.0

			print("PLAYER HIT BY GROUND SLAM")

		# Other enemies
		elif body.is_in_group("enemy") and body != enemy:

			var direction = (
				body.global_position
				- enemy.global_position
			)

			direction.y = 0.0

			if direction.length() > 0.1:
				direction = direction.normalized()

			body.velocity.x = direction.x * 5.0
			body.velocity.z = direction.z * 5.0
			body.velocity.y = 10.0

			print("ENEMY HIT BY GROUND SLAM: ", body.name)

	ground_slam_active = false

	await get_tree().create_timer(1.0).timeout

	attack_finished = true


func process(_delta: float) -> void:

	if attack_finished:
		attack_finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:

	# Keep the boss stationary during attacks.
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	# Apply gravity while airborne.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:

	punch_hitbox.monitoring = false
	ground_slam_active = false
