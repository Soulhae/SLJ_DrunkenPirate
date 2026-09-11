extends State
class_name BossHeal

@onready var enemy: CharacterBody3D = get_owner()
@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"
@onready var mesh: MeshInstance3D = $"../../boss/Armature/Skeleton3D/Rapier"

@export var heal_amount: int = 25
@export var heal_time: float = 2.0
@export var heal_speed: float = 3.0

var original_material: Material
var original_color: Color

var heal_finished: bool = false


func enter() -> void:
	heal_finished = false

	player = get_tree().get_first_node_in_group("player")

	if enemy.heals_used >= enemy.max_boss_heals:
		print("BOSS HAS NO HEALS LEFT")
		Transitioned.emit(self, "bossrecovery")
		return

	animation_player.play("walk")
	# Heal - Bright Green
	flash_attack_color(Color(0.1, 1.0, 0.5))
	print("========== BOSS HEALING ==========")

	heal()


func heal() -> void:
	await get_tree().create_timer(heal_time).timeout

	if not is_inside_tree():
		return

	enemy.Health = min(
		enemy.Health + heal_amount,
		enemy.MaxHealth
	)

	enemy.heals_used += 1

	print("BOSS HEALED FOR ", heal_amount)
	print("BOSS HEALTH: ", enemy.Health)
	print("BOSS HEALS USED: ", enemy.heals_used)

	heal_finished = true


func process(_delta: float) -> void:
	if heal_finished:
		heal_finished = false
		Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float) -> void:
	if player == null:
		return

	# Move slowly toward the player while healing.
	var direction: Vector3 = player.global_position - enemy.global_position
	direction.y = 0.0

	if direction.length() > 0.1:
		direction = direction.normalized()

		enemy.look_at(
			enemy.global_position + direction,
			Vector3.UP
		)

		enemy.velocity.x = direction.x * heal_speed
		enemy.velocity.z = direction.z * heal_speed
	else:
		enemy.velocity.x = 0.0
		enemy.velocity.z = 0.0

	# Gravity
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()


func exit() -> void:
	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

func flash_attack_color(color: Color) -> void:
	if mesh == null:
		return

	if mesh.material_override == null:
		original_material = mesh.get_active_material(0)

		if original_material == null:
			return

		var new_material = original_material.duplicate()
		mesh.material_override = new_material

	var material = mesh.material_override

	if material is StandardMaterial3D:
		original_color = material.albedo_color
		material.albedo_color = color

		await get_tree().create_timer(0.2).timeout

		if not is_inside_tree():
			return

		material.albedo_color = original_color
