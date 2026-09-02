extends State
class_name BossAttack

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

var selected_attack := -1
var last_attack := -1
var can_transition := false

# Tracks consecutive attacks
var slam_streak := 0
var clone_streak := 0

# Far-range bomb sequence
var bombs_remaining := 0


func enter() -> void:
	can_transition = false
	enemy.velocity = Vector3.ZERO

	var distance = enemy.global_position.distance_to(player.global_position)

	print("BOSS ATTACK DISTANCE: ", distance)


	# =========================
	# 0–5m: PUNCH / GRAB
	# =========================
	if distance <= enemy.AttackReach:

		# 50% Punch
		# 50% Grab

		selected_attack = randi_range(0, 1)

		if selected_attack == last_attack:
			selected_attack = 1 if selected_attack == 0 else 0


	# =========================
	# 5–10m: SLAM / CLONE
	# =========================
	elif distance <= 10.0:

		# Almost 50 / 50
	#
	# Slam can happen up to 3 times.
	# Clone can happen up to 3 times.
	# Neither can happen 4 times in a row.

		if slam_streak >= 3:

			# Force Clone after 3 Slams.
			selected_attack = 3

		elif clone_streak >= 3:

			# Force Slam after 3 Clones.
			selected_attack = 2

		else:

			# 50 / 50 random choice.
			selected_attack = 2 if randf() < 0.50 else 3


	# =========================
	# 10–15m: BOMB / CLONE
	# =========================
	elif distance <= 15.0:

		# Bomb = 75%
		# Clone = 25%
		#
		# Clone cannot happen twice.
		# Bomb can happen many times.

		if last_attack == 3:

			selected_attack = 4

		else:

			if randf() < 0.75:
				selected_attack = 4
			else:
				selected_attack = 3


	# =========================
	# 15–20m: DIVE / BOMB
	# =========================
	else:

		# Dive = 70%
		# Bomb sequence = 30%

		choose_far_attack()


	# Update streaks
	if selected_attack == 2:
		slam_streak += 1
	else:
		slam_streak = 0

	if selected_attack == 3:
		clone_streak += 1
	else:
		clone_streak = 0

	last_attack = selected_attack
	can_transition = true


func choose_far_attack() -> void:

	# Continue an existing Bomb sequence.
	if bombs_remaining > 0:

		selected_attack = 4
		bombs_remaining -= 1

		print("FAR RANGE: BOMB")
		print("BOMBS REMAINING: ", bombs_remaining)

		return


	# Start a new sequence.
	# 70% Dive
	# 30% Bomb sequence

	if randf() < 0.70:

		selected_attack = 5

		print("FAR RANGE: DIVE")

	else:

		bombs_remaining = randi_range(3, 5)

		selected_attack = 4
		bombs_remaining -= 1

		print("FAR RANGE: STARTING BOMB SEQUENCE")
		print("BOMBS REMAINING: ", bombs_remaining)


func process(_delta: float) -> void:

	if not can_transition:
		return

	can_transition = false

	match selected_attack:

		0:
			print("TRANSITIONING TO PUNCH")
			Transitioned.emit(self, "bosspunch")

		1:
			print("TRANSITIONING TO GRAB")
			Transitioned.emit(self, "bossgrab")

		2:
			print("TRANSITIONING TO GROUND SLAM")
			Transitioned.emit(self, "bossgroundslam")

		3:
			print("TRANSITIONING TO SALT CLONE")
			Transitioned.emit(self, "bosssaltclone")

		4:
			print("TRANSITIONING TO SALT BOMB")
			Transitioned.emit(self, "bosssaltbomb")

		5:
			print("TRANSITIONING TO DIVE")
			Transitioned.emit(self, "bossdive")


func physics_process(delta: float) -> void:

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	can_transition = false
