extends State
class_name BossPunch

@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy: CharacterBody3D = get_owner()
@onready var punch_hitbox: Area3D = $"../../BOX/punch_hitbox"
@onready var punch1 = $"../../punch"
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"

@export var punch_damage: int = 8
@export var wind_up_time: float = 0.6
@export var hit_time: float = 0.2


func enter() -> void:
	animation_player.play("punch")
	punch_hitbox.monitoring = false
	enemy.velocity = Vector3.ZERO

	punch()


func punch() -> void:

	print("PUNCH WIND UP")

	await get_tree().create_timer(wind_up_time).timeout

	if not is_inside_tree():
		return

	print("PUNCH ATTACK")

	punch_hitbox.monitoring = true

	await get_tree().create_timer(hit_time).timeout

	for body in punch_hitbox.get_overlapping_bodies():

		if body.is_in_group("player"):

			var damage = punch_damage

			if enemy.phase_2_started:
				damage = 12

			body.take_damage(damage, enemy)

			var punch_direction = -enemy.global_transform.basis.z

			punch_direction.y = 0.0
			punch_direction = punch_direction.normalized()

			body.velocity.x = punch_direction.x * 8.0
			body.velocity.z = punch_direction.z * 8.0
			body.velocity.y = 3.0

			print("PLAYER PUNCHED")
			punch1.play()

	punch_hitbox.monitoring = false

	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:

	if player != null:

		var direction = player.global_position - enemy.global_position
		direction.y = 0.0

		if direction.length() > 0.1:
			direction = direction.normalized()

			enemy.look_at(
				enemy.global_position + direction,
				Vector3.UP
			)

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	punch_hitbox.monitoring = false
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0
