extends State
class_name BossAttack

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()

var selected_attack := -1
var can_transition := false


func enter():

	can_transition = false
	enemy.velocity = Vector3.ZERO

	var distance = enemy.global_position.distance_to(
		player.global_position
	)

	print("BOSS ATTACK DISTANCE: ", distance)


	# ========================================================
	# CLOSE RANGE
	# ========================================================

	if distance <= enemy.AttackReach:

		# 0 = Punch
		# 3 = Grab
		selected_attack = randi_range(0, 1)

		if selected_attack == 1:
			selected_attack = 3


	# ========================================================
	# MID RANGE
	# ========================================================

	elif distance <= enemy.SlamReach:

		# Ground Slam
		selected_attack = 2


	# ========================================================
	# LONG RANGE
	# ========================================================

	else:

		# 4 = Salt Bomb
		# 5 = Dive

		selected_attack = randi_range(4, 5)


	can_transition = true


func process(_delta):

	if not can_transition:
		return

	can_transition = false


	match selected_attack:

		0:
			print("TRANSITIONING TO PUNCH")
			Transitioned.emit(self,"bosspunch")

		2:
			print("TRANSITIONING TO GROUND SLAM")
			Transitioned.emit(self,"bossgroundslam")

		3:
			print("TRANSITIONING TO GRAB")
			Transitioned.emit(self,"bossgrab")

		4:
			print("TRANSITIONING TO SALT BOMB")
			Transitioned.emit(self,"bosssaltbomb")

		5:
			print("TRANSITIONING TO DIVE")
			Transitioned.emit(self,"bossdive")


func physics_process(delta):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit():

	can_transition = false
