extends State
class_name BossAttack

# Reference to the enemy and its attack hitbox.
# Reference to the player and enemy.
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

@onready var hitbox: Area3D = $"../../BOX/Hitbox"

# Keeps track of whether the current attack has finished.
var attack_finished: bool = false


# Choose and start an attack.
func enter():
	attack_finished = false
	hitbox.monitoring = false
	
	choose_attack()
# Stores the previous attack.
var last_attack: int = -1


# Choose which attack to use.
func choose_attack():

	# Get the distance between the boss and player.
	var distance_to_player = enemy.global_position.distance_to(
		player.global_position
	)

	var possible_attacks: Array[int] = []
	var weights: Array[float] = []


	# Close range.
	if distance_to_player <= 4.0:
		possible_attacks = [0, 1]
		weights = [0.6, 0.4]


	# Mid range.
	elif distance_to_player <= 12.0:
		possible_attacks = [1, 2]
		weights = [0.4, 0.6]


	# Long range.
	else:
		possible_attacks = [2]
		weights = [1.0]


	# Avoid using the same attack twice in a row.
	if possible_attacks.size() > 1 and last_attack in possible_attacks:
		var index = possible_attacks.find(last_attack)
		possible_attacks.remove_at(index)
		weights.remove_at(index)


	# Choose an attack.
	var attack = choose_weighted_attack(possible_attacks, weights)

	last_attack = attack


	match attack:
		0:
			bite()
		1:
			tail_slam()
		2:
			water_spit()


# Choose an attack using weighted randomness.
func choose_weighted_attack(attacks: Array[int], weights: Array[float]) -> int:

	var total_weight: float = 0.0

	for weight in weights:
		total_weight += weight

	var random_value = randf_range(0.0, total_weight)

	for i in range(attacks.size()):
		random_value -= weights[i]

		if random_value <= 0.0:
			return attacks[i]

	return attacks[attacks.size() - 1]

	

# ATTACK 0 - BITE


func bite():

	print("BITE WIND UP")

	# Wait during the bite wind-up.
	await get_tree().create_timer(0.8).timeout

	# The bite is now active.
	print("BITE ATTACK")

	# Enable the melee hitbox.
	hitbox.monitoring = true

	# Keep the hitbox active for a short amount of time.
	await get_tree().create_timer(0.2).timeout

	# Check whether the player was hit.
	check_melee_hitbox()

	# Disable the hitbox after the attack.
	hitbox.monitoring = false

	# Finish the attack.
	attack_finished = true



# ATTACK 1 - TAIL SLAM


func tail_slam():

	print("TAIL SLAM WIND UP")

	# Tail slam has a longer wind-up.
	await get_tree().create_timer(1.2).timeout

	print("TAIL SLAM ATTACK")

	# Enable the hitbox.
	hitbox.monitoring = true

	# Tail slam stays active longer than the bite.
	await get_tree().create_timer(0.35).timeout

	# Check for the player.
	check_melee_hitbox()

	# Disable the hitbox.
	hitbox.monitoring = false

	# Finish the attack.
	attack_finished = true


# ATTACK 2 - WATER SPIT


func water_spit():

	print("WATER SPIT WIND UP")

	# Longer wind-up for a ranged attack.
	await get_tree().create_timer(1.5).timeout

	print("WATER SPIT ATTACK")

	# The actual projectile can be added later.
	# This attack does not use the melee hitbox.

	attack_finished = true



# MELEE HIT DETECTION


func check_melee_hitbox():

	var bodies = hitbox.get_overlapping_bodies()

	for body in bodies:

		if body.is_in_group("player"):
			print("PLAYER HURT")



# ATTACK STATE


func process(_delta: float):

	# Wait until the selected attack has finished.
	if attack_finished:
		Transitioned.emit(self, "bossrecovery")
		attack_finished = false


# Keep the boss still while attacking.
func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


# Clean up the hitbox if the state is exited.
func exit():
	hitbox.monitoring = false
