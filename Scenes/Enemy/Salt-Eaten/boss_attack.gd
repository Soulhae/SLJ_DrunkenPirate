extends State
class_name BossAttack

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

var selected_attack := -1
var last_attack := -1
var can_transition := false

# Tracks consecutive slams
var slam_streak := 0

# Tracks consecutive clones
var clone_streak := 0

# Far-range bomb sequence
var bombs_remaining := 0


# =========================================
# CLONE LIMIT / INTERVAL
# =========================================

# Minimum time between clone spawns
@export var clone_interval: float = 5.0

# Maximum clones alive at once
@export var max_clones: int = 2

# Time when the last clone spawned
var last_clone_time: int = -999999


func enter() -> void:

	can_transition = false
	enemy.velocity = Vector3.ZERO

	var distance = enemy.global_position.distance_to(
		player.global_position
	)

	print("BOSS ATTACK DISTANCE: ", distance)


	# =========================
	# PHASE 2 HEAL
	# =========================

	if enemy.phase_2_started and enemy.heals_used < enemy.max_boss_heals:

		if randf() < 0.25:

			selected_attack = 6

			print("BOSS CHOSE TO HEAL")

			can_transition = true
			return


	# =========================
	# 0–5m
	# PUNCH / GRAB / SLAM
	# =========================

	if distance <= enemy.AttackReach:

		# If boss has slammed 3 times,
		# don't allow another slam.
		if slam_streak >= 3:

			selected_attack = randi_range(0, 1)

		else:

			# Punch = 40%
			# Grab  = 40%
			# Slam  = 20%

			var roll := randf()

			if roll < 0.40:

				selected_attack = 0

			elif roll < 0.80:

				selected_attack = 1

			else:

				selected_attack = 2


		# Don't repeat Punch or Grab twice
		# in a row.
		if selected_attack == last_attack:

			if selected_attack == 0:

				selected_attack = 1

			elif selected_attack == 1:

				selected_attack = 0


	# =========================
	# 5–10m
	# SLAM / CLONE
	# =========================

	elif distance <= 10.0:

		var clone_allowed := can_spawn_clone()

		if clone_allowed:

			# Clone = 30%
			# Slam  = 70%

			if randf() < 0.30:

				selected_attack = 3

				print("5–10M: CLONE")

			else:

				selected_attack = 2

				print("5–10M: SLAM")

		else:

			# Clone unavailable
			# Only Slam

			selected_attack = 2

			print("5–10M: CLONE BLOCKED - SLAM")


	# =========================
	# 10–15m
	# BOMB / CLONE
	# =========================

	elif distance <= 15.0:

		var clone_allowed := can_spawn_clone()

		if clone_allowed:

			# Clone = 20%
			# Bomb  = 80%

			if randf() < 0.20:

				selected_attack = 3

				print("10–15M: CLONE")

			else:

				selected_attack = 4

				print("10–15M: BOMB")

		else:

			# Clone unavailable
			# Only Bomb

			selected_attack = 4

			print("10–15M: CLONE BLOCKED - BOMB")


	# =========================
	# 15m+
	# DIVE / BOMB SEQUENCE
	# =========================

	else:

		choose_far_attack()


	# =========================
	# UPDATE SLAM STREAK
	# =========================

	if selected_attack == 2:

		slam_streak += 1

	else:

		slam_streak = 0


	# =========================
	# UPDATE CLONE STREAK
	# =========================

	if selected_attack == 3:

		clone_streak += 1

	else:

		clone_streak = 0


	# =========================
	# RECORD CLONE SPAWN
	# =========================

	if selected_attack == 3:

		last_clone_time = Time.get_ticks_msec()

		print("CLONE SPAWNED")
		print(
			"NEXT CLONE AVAILABLE IN: ",
			clone_interval,
			" SECONDS"
		)


	# =========================
	# UPDATE LAST ATTACK
	# =========================

	# Don't count heal as an attack.
	if selected_attack != 6:

		last_attack = selected_attack


	can_transition = true


# =========================================
# CAN SPAWN CLONE?
# =========================================

func can_spawn_clone() -> bool:

	# Count currently alive clones
	var current_clones := get_tree().get_nodes_in_group(
		"boss_clone"
	).size()

	# Maximum 2 alive
	if current_clones >= max_clones:

		print(
			"CLONE BLOCKED - MAX CLONES ALIVE: ",
			current_clones
		)

		return false


	# Check time since last clone
	var current_time := Time.get_ticks_msec()

	var time_since_clone := (
		current_time - last_clone_time
	) / 1000.0


	if time_since_clone < clone_interval:

		print(
			"CLONE BLOCKED - COOLDOWN: ",
			clone_interval - time_since_clone,
			" SECONDS"
		)

		return false


	return true


# =========================================
# FAR RANGE ATTACK
# =========================================

func choose_far_attack() -> void:

	# Continue existing bomb sequence
	if bombs_remaining > 0:

		selected_attack = 4

		bombs_remaining -= 1

		print("FAR RANGE: BOMB")
		print(
			"BOMBS REMAINING: ",
			bombs_remaining
		)

		return


	# Start a new sequence
	#
	# Dive = 70%
	# Bomb sequence = 30%

	if randf() < 0.70:

		selected_attack = 5

		print("FAR RANGE: DIVE")

	else:

		bombs_remaining = randi_range(3, 5)

		selected_attack = 4

		bombs_remaining -= 1

		print("FAR RANGE: STARTING BOMB SEQUENCE")
		print(
			"BOMBS REMAINING: ",
			bombs_remaining
		)


# =========================================
# PROCESS
# =========================================

func process(_delta: float) -> void:

	if not can_transition:

		return

	can_transition = false

	match selected_attack:

		0:

			print("TRANSITIONING TO PUNCH")

			Transitioned.emit(
				self,
				"bosspunch"
			)


		1:

			print("TRANSITIONING TO GRAB")

			Transitioned.emit(
				self,
				"bossgrab"
			)


		2:

			print("TRANSITIONING TO GROUND SLAM")

			Transitioned.emit(
				self,
				"bossgroundslam"
			)


		3:

			print("TRANSITIONING TO SALT CLONE")

			Transitioned.emit(
				self,
				"bosssaltclone"
			)


		4:

			print("TRANSITIONING TO SALT BOMB")

			Transitioned.emit(
				self,
				"bosssaltbomb"
			)


		5:

			print("TRANSITIONING TO DIVE")

			Transitioned.emit(
				self,
				"bossdive"
			)


		6:

			print("TRANSITIONING TO BOSS HEAL")

			Transitioned.emit(
				self,
				"bossheal"
			)


# =========================================
# PHYSICS
# =========================================

func physics_process(_delta: float) -> void:

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():

		enemy.velocity += enemy.get_gravity() * _delta

	enemy.move_and_slide()


# =========================================
# EXIT
# =========================================

func exit() -> void:

	can_transition = false
