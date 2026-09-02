extends "res://Scripts/StateMachine/state.gd"
class_name EnemyAttack

# References
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var hitbox: Area3D = $"../../BOX/Hitbox"

# Attack settings
@export var attack_damage: int = 2
@export var attack_cooldown: float = 1.0
@export var attack_duration: float = 0.2

var cooldown_timer: float = 0.0
var attack_timer: float = 0.0
var attack_active: bool = false
var player_hit: bool = false


func enter() -> void:
	# Reset attack
	cooldown_timer = attack_cooldown
	attack_timer = 0.0
	attack_active = false
	player_hit = false

	hitbox.monitoring = false


func process(delta: float) -> void:

	# ========================================================
	# CHECK DISTANCE
	# ========================================================

	var distance = enemy.global_position.distance_to(player.global_position)

	if distance > enemy.AttackReach:
		hitbox.monitoring = false
		attack_active = false

		Transitioned.emit(self, "enemychase")
		return


	# ========================================================
	# COOLDOWN / WIND-UP
	# ========================================================

	if not attack_active:

		cooldown_timer -= delta

		if cooldown_timer <= 0.0:

			attack_active = true
			player_hit = false
			attack_timer = attack_duration

			hitbox.monitoring = true

			print("ENEMY ATTACK")


	# ========================================================
	# ATTACK
	# ========================================================

	else:

		attack_timer -= delta

		if attack_timer <= 0.0:

			attack_active = false
			hitbox.monitoring = false

			print("ENEMY ATTACK FINISHED")

			Transitioned.emit(self, "enemyrecovery")


func physics_process(delta: float) -> void:

	# ========================================================
	# FACE PLAYER
	# ========================================================

	var direction = player.global_position - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:

		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)


	# ========================================================
	# STOP MOVING
	# ========================================================

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0


	# ========================================================
	# GRAVITY
	# ========================================================

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


	# ========================================================
	# DAMAGE PLAYER
	# ========================================================

	if attack_active:

		for body in hitbox.get_overlapping_bodies():

			if body.is_in_group("player") and not player_hit:

				body.take_damage(attack_damage)

				player_hit = true

				print("PLAYER HURT")


func exit() -> void:

	# Make sure the hitbox is disabled
	hitbox.monitoring = false
	attack_active = false
