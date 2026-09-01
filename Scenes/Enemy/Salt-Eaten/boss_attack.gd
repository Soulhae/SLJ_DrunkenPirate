extends State
class_name BossAttack

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

var selected_attack := -1
var last_attack := -1
var can_transition := false

func enter() -> void:
	can_transition = false
	enemy.velocity = Vector3.ZERO

	var distance = enemy.global_position.distance_to(player.global_position)
	print("BOSS ATTACK DISTANCE: ", distance)

	if distance <= enemy.AttackReach:
		# CLOSE: Punch / Grab
		selected_attack = randi_range(0, 1)

	elif distance <= enemy.SlamReach:
		# MID: Ground Slam / Salt Clone
		selected_attack = randi_range(2, 3)

	else:
		# LONG: Salt Bomb / Dive
		selected_attack = randi_range(4, 5)

	# Don't use the same attack twice.
	if selected_attack == last_attack:
		if distance <= enemy.AttackReach:
			selected_attack = 1 if selected_attack == 0 else 0

		elif distance <= enemy.SlamReach:
			selected_attack = 3 if selected_attack == 2 else 2

		else:
			selected_attack = 5 if selected_attack == 4 else 4

	last_attack = selected_attack

	can_transition = true


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
