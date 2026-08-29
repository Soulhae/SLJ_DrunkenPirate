extends CharacterBody3D

@export var Health: int = 100

const SPEED = 10.0
const JUMP_VELOCITY = 4.5

@export var mouse_sens: float = 0.005
@export var controller_sens: float = 4

var enemy_target: CharacterBody3D

@onready var visuals: Node3D = $Visuals
@onready var h_pivot: Node3D = $HPivot
@onready var v_pivot: Node3D = $HPivot/VPivot
@onready var lock_target_range: Area3D = $LockTargetRange
@onready var camera_3d: Camera3D = $HPivot/VPivot/SpringArm3D/Camera3D

@export var water: MeshInstance3D

var last_position: Vector3



func _ready() -> void:
	last_position = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not enemy_target:
			h_pivot.rotation.y -= event.relative.x * mouse_sens;
			v_pivot.rotation.x -= event.relative.y * mouse_sens;
			v_pivot.rotation.x = clamp(
				v_pivot.rotation.x,
				-PI/3,
				PI/4
			);
			return;
		#else:
			#var new_enemy_position: Vector3 = Vector3(enemy_target.global_position.x, 
					#h_pivot.global_position.y, enemy_target.global_position.z)
			#h_pivot.look_at(new_enemy_position)
	
	if event.is_action_pressed("lock_target"):
		if enemy_target != null:
			enemy_target = null
			return
		
		var enemies_in_range = []
		var closest_distance: float = 0.75 # tweakable, -1 is 'eyes behind the head', 0 is 180°, 1 is directly in front
		var closest_enemy: CharacterBody3D = null
		var enemy_vector: Vector3
		var camera_vector: Vector3 = -camera_3d.global_transform.basis.z.normalized()
		var enemy_distance_to_center: float
		if lock_target_range.has_overlapping_bodies():
			for body in lock_target_range.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					enemy_vector = (body.global_position - camera_3d.global_position).normalized()
					enemy_distance_to_center = camera_vector.dot(enemy_vector)
					if enemy_distance_to_center > closest_distance:
						closest_enemy = body
						closest_distance = enemy_distance_to_center
					enemies_in_range.append(body)
			if check_enemy_is_visible(closest_enemy):
				enemy_target = closest_enemy
			else:
				enemy_target = null
			#print("Enemies in range (%s): %s" %[enemies_in_range.size(), enemies_in_range])
			#print("Locked enemy ", enemy_target)


func _process(delta: float) -> void:
	if not enemy_target:
		var input_dir := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		
		h_pivot.rotation.y -= input_dir.x * controller_sens * delta;
		v_pivot.rotation.x -= input_dir.y * controller_sens * delta;
		v_pivot.rotation.x = clamp(
			v_pivot.rotation.x,
			-PI/3,
			PI/4
		);
	else:
		var new_enemy_position: Vector3 = Vector3(enemy_target.global_position.x, 
				h_pivot.global_position.y, enemy_target.global_position.z)
		h_pivot.look_at(new_enemy_position)


func _physics_process(_delta: float) -> void:
	if water == null:
		return

	if global_position.distance_to(last_position) > 0.5:
		water.create_ripple(global_position)
		last_position = global_position


func _on_lock_target_range_body_entered(_body: Node3D) -> void:
	#if body.is_in_group("enemy"):
		#print("Enemy: %s in range" % body)
	pass


func _on_lock_target_range_body_exited(body: Node3D) -> void:
	if body == enemy_target:
		enemy_target = null
	
	#if body.is_in_group("enemy"):
		#print("Enemy: %s now out of range" % body.name)


func check_enemy_is_visible(closest_enemy: CharacterBody3D) -> bool:
	if not closest_enemy:
		return false
	
	var ray_from : Vector3 = camera_3d.global_position
	var ray_to : Vector3 = closest_enemy.global_position
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.create(ray_from, ray_to)
	ray_query.exclude = [self.get_rid()]
	var ray_result = space.intersect_ray(ray_query)
	
	#print(ray_result)
	return true if ray_result and ray_result.collider == closest_enemy else false


func get_camera_relative_input() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	return (h_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()


func update_visuals_rotation(direction: Vector3, delta: float) -> void:
	var target_angle: float
	
	if enemy_target:
		var enemy_to_player_vector: Vector3 = (enemy_target.global_position - global_position).normalized()
		target_angle = atan2(-enemy_to_player_vector.x, -enemy_to_player_vector.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 5 * delta)
	elif direction:
		target_angle = atan2(-direction.x, -direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 5 * delta)
		
func take_damage(amount: int) -> void:
	Health -= amount
	print("PLAYER HEALTH: ", Health)

	if Health <= 0:
		Health = 0
		print("PLAYER DIED")
