extends State
class_name EnemyAttack

# References
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var hitbox: Area3D = $"../../BOX/Hitbox"

var player_hit: bool = false

# Attack settings
var attack_finished: bool = false
var attack_cooldown = 1.0
var attack_timer = 0.0
var attack_duration = 0.2
var attack_active = false
@export var attack_damage: int = 10


func enter():
	# Reset attack
	attack_timer = 0.0
	attack_duration = 0.2
	attack_active = false
	attack_finished = false
	player_hit = false
	hitbox.monitoring = false

	#print("Swing Distance: ", enemy.global_position.distance_to(player.global_position))


func process(delta: float):
	# Check distance
	var distance = enemy.global_position.distance_to(player.global_position)

	if distance > enemy.AttackReach:
		hitbox.monitoring = false
		attack_active = false
		Transitioned.emit(self, "enemychase")
		return

	# Attack cooldown
	attack_timer -= delta

	if attack_timer <= 0.0 and not attack_active:
		attack_active = true
		player_hit = false
		attack_duration = 0.2
		attack_timer = attack_cooldown
		hitbox.monitoring = true
		#print("Attack!")


func physics_process(delta: float):
	# Face player
	var direction = (
		player.global_position - enemy.global_position
	).normalized()

	if direction.length() > 0.1:
		enemy.look_at(
			enemy.global_position + Vector3(direction.x, 0, direction.z),
			Vector3.UP
		)

	# Apply gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()

	# Turn attack hitbox off
	if attack_active:
		attack_duration -= delta

		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("player") and not player_hit:
				body.take_damage(attack_damage)
				player_hit = true
				print("PLAYER HURT")

	if attack_duration <= 0.0:
		attack_active = false
		hitbox.monitoring = false
		attack_duration = 0.2
		attack_finished = true

	if attack_finished:
		attack_finished = false
		Transitioned.emit(self, "enemyrecovery")


func exit():
	# Make sure hitbox is disabled
	hitbox.monitoring = false
	attack_active = false
