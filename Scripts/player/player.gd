extends CharacterBody3D

@export var Health: int = 100
@onready var block_label: Label = $"../UI/BLOCK"
@onready var damage_label: Label = $"../UI/DEMAGE"
@onready var hurt_flash: ColorRect = $"../UI/HurtFlash"
@onready var hurt = $Hurt
const JUMP_VELOCITY = 6.5
@export var damage_number_scene: PackedScene
@export var mouse_sens: float = 0.005
@export var controller_sens: float = 4

var shake_strength: float = 0.0
var shake_time: float = 0.0
var shake_duration: float = 0.0
var camera_original_rotation: Vector3

@export var max_heals: int = 3
var heals_left: int
@export var MaxHealth: int = 100

var enemy_target: CharacterBody3D
var move_speed: float = 10.0

@onready var visuals: Node3D = $Visuals
@onready var h_pivot: Node3D = $HPivot
@onready var v_pivot: Node3D = $HPivot/VPivot
@onready var lock_target_range: Area3D = $LockTargetRange
@onready var camera_3d: Camera3D = $HPivot/VPivot/SpringArm3D/Camera3D
@onready var spring_arm: SpringArm3D = $HPivot/VPivot/SpringArm3D
@onready var camera: Camera3D = $HPivot/VPivot/SpringArm3D/Camera3D

@export var water: MeshInstance3D
@onready var state_machine: StateMachine = $StateMachine
var last_position: Vector3

var drunk_timer: float = 0.0
var drunk: bool = false
var drunk_strength: float = 0.35
var drunk_direction: Vector3 = Vector3.ZERO
var drunk_change_timer: float = 0.0
var drunk_camera_time: float = 0.0
var drunk_fov: float = 75.0

func _ready() -> void:
	heals_left = max_heals
	last_position = global_position
	camera_original_rotation = camera.rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	hurt_flash.color.a = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not enemy_target:
			h_pivot.rotation.y -= event.relative.x * mouse_sens
			v_pivot.rotation.x -= event.relative.y * mouse_sens
			v_pivot.rotation.x = clamp(v_pivot.rotation.x, -PI / 3, PI / 4)
			return

	if event.is_action_pressed("lock_target"):
		if enemy_target != null:
			enemy_target = null
			return

		var enemies_in_range = []
		var closest_distance: float = 0.75
		var closest_enemy: CharacterBody3D = null
		var camera_vector: Vector3 = -camera_3d.global_transform.basis.z.normalized()

		if lock_target_range.has_overlapping_bodies():
			for body in lock_target_range.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					var enemy_vector = (body.global_position - camera_3d.global_position).normalized()
					var enemy_distance_to_center = camera_vector.dot(enemy_vector)

					if enemy_distance_to_center > closest_distance:
						closest_enemy = body
						closest_distance = enemy_distance_to_center

					enemies_in_range.append(body)

			if check_enemy_is_visible(closest_enemy):
				enemy_target = closest_enemy
			else:
				enemy_target = null

func _process(delta: float) -> void:
	if state_machine.current_state.name == "PlayerBlock":
		var block_state: PlayerBlock = state_machine.current_state as PlayerBlock

		if block_state.is_parrying():
			block_label.text = "PARRY!"
		else:
			block_label.text = "BLOCK"

		block_label.visible = true
	else:
		block_label.visible = false

	if drunk:
		drunk_timer -= delta
		drunk_camera_time += delta

		var wobble_x = sin(drunk_camera_time * 2.5) * 0.04
		var wobble_z = cos(drunk_camera_time * 2.0) * 0.04

		spring_arm.rotation.x = wobble_x
		spring_arm.rotation.z = wobble_z
		spring_arm.position.y = sin(drunk_camera_time * 3.0) * 0.05

		var fov_wobble = sin(drunk_camera_time * 1.8) * 4.0
		camera.fov = drunk_fov + fov_wobble

		if drunk_timer <= 0.0:
			drunk = false
			drunk_timer = 0.0
			drunk_camera_time = 0.0
			spring_arm.rotation.x = 0.0
			spring_arm.rotation.z = 0.0
			spring_arm.position.y = 0.0
			camera.fov = drunk_fov
			print("NO LONGER DRUNK")

	# CAMERA SHAKE
	if shake_time > 0.0:
		shake_time -= delta
		var shake_fade = shake_time / shake_duration

		camera.rotation = camera_original_rotation + Vector3(
			randf_range(-shake_strength, shake_strength) * shake_fade,
			randf_range(-shake_strength, shake_strength) * shake_fade,
			randf_range(-shake_strength, shake_strength) * shake_fade
		)

		if shake_time <= 0.0:
			shake_time = 0.0
			camera.rotation = camera_original_rotation

	if not enemy_target:
		var input_dir := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		h_pivot.rotation.y -= input_dir.x * controller_sens * delta
		v_pivot.rotation.x -= input_dir.y * controller_sens * delta
		v_pivot.rotation.x = clamp(v_pivot.rotation.x, -PI / 3, PI / 4)
	else:
		var new_enemy_position = Vector3(enemy_target.global_position.x, h_pivot.global_position.y, enemy_target.global_position.z)
		h_pivot.look_at(new_enemy_position)

func _physics_process(_delta: float) -> void:
	if water == null:
		return

	if global_position.distance_to(last_position) > 0.5:
		water.create_ripple(global_position)
		last_position = global_position

func _on_lock_target_range_body_entered(_body: Node3D) -> void:
	pass

func _on_lock_target_range_body_exited(body: Node3D) -> void:
	if body == enemy_target:
		enemy_target = null

func check_enemy_is_visible(closest_enemy: CharacterBody3D) -> bool:
	if not closest_enemy:
		return false

	var ray_from = camera_3d.global_position
	var ray_to = closest_enemy.global_position
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	ray_query.exclude = [self.get_rid()]
	var ray_result = space.intersect_ray(ray_query)

	return true if ray_result and ray_result.collider == closest_enemy else false

func get_camera_relative_input() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	return (h_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func update_visuals_rotation(direction: Vector3, delta: float) -> void:
	var target_angle: float

	if enemy_target:
		var enemy_to_player_vector = (enemy_target.global_position - global_position).normalized()
		target_angle = atan2(-enemy_to_player_vector.x, -enemy_to_player_vector.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 5 * delta)
	elif direction:
		target_angle = atan2(-direction.x, -direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 5 * delta)

func take_damage(amount: int, attacker: Node = null) -> void:
	if state_machine.current_state.name == "PlayerBlock":
		var block_state: PlayerBlock = state_machine.current_state as PlayerBlock

		if block_state.is_parrying():
			print("========== PARRIED! ==========")
			block_label.text = "PARRY!"
			block_label.visible = true

			if attacker != null:
				activate_parry_stun(attacker)

			await get_tree().create_timer(0.5).timeout

			if state_machine.current_state.name == "PlayerBlock":
				block_label.text = "BLOCK"
				block_label.visible = true
			else:
				block_label.visible = false
			return

		amount = int(amount * 0.7)
		print("BLOCKED! Damage: ", amount)

	Health -= amount
	print("PLAYER HEALTH: ", Health)
	show_hurt_flash()
	shake_camera(0.035, 0.10)
	show_damage_number(amount, global_position + Vector3(0, 1.5, 0))
	hurt.play()

	damage_label.text = "-" + str(amount)
	damage_label.visible = true

	await get_tree().create_timer(0.5).timeout
	damage_label.visible = false

	if Health <= 0:
		Health = 0
		print("======PLAYER DIED================")
		get_tree().reload_current_scene()

func activate_parry_stun(attacker: Node) -> void:
	if not is_instance_valid(attacker):
		return

	var attacker_state_machine = attacker.get_node_or_null("StateMachine")
	if attacker_state_machine == null:
		return

	for state in attacker_state_machine.get_children():
		if state.name.to_lower().ends_with("stun"):
			print("STUNNING: ", attacker.name)
			attacker_state_machine.current_state.Transitioned.emit(
				attacker_state_machine.current_state,
				state.name.to_lower()
			)
			return

func show_damage_number(amount: int, position: Vector3) -> void:
	var damage_number = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(damage_number)
	damage_number.text_color = Color.RED
	damage_number.global_position = position
	damage_number.setup(-amount)

func shake_camera(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_duration = duration
	shake_time = duration

func hit_stop(duration: float) -> void:
	Engine.time_scale = 0.0
	await get_tree().create_timer(
		duration,
		true,
		false,
		true
	).timeout
	Engine.time_scale = 1.0

func show_hurt_flash() -> void:
	var flash_color = hurt_flash.color
	flash_color.a = 0.35
	hurt_flash.color = flash_color

	var tween = create_tween()
	tween.tween_property(hurt_flash, "color:a", 0.0, 0.1)
