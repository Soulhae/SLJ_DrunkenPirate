extends CharacterBody3D


const SPEED = 10.0
const JUMP_VELOCITY = 4.5

@export var mouse_sens: float = 0.005
@export var controller_sens: float = 4

@onready var visuals: Node3D = $Visuals
@onready var h_pivot: Node3D = $HPivot
@onready var v_pivot: Node3D = $HPivot/VPivot
@onready var lock_target_range: Area3D = $LockTargetRange


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		h_pivot.rotation.y -= event.relative.x * mouse_sens;
		v_pivot.rotation.x -= event.relative.y * mouse_sens;
		v_pivot.rotation.x = clamp(
			v_pivot.rotation.x,
			-PI/3,
			PI/4
		);
		return;
	
	if event.is_action_pressed("lock_target"):
		var enemies_in_range = []
		if lock_target_range.has_overlapping_bodies():
			for body in lock_target_range.get_overlapping_bodies():
				if body.is_in_group("enemy"):
					enemies_in_range.append(body)
			print("Enemies in range (%s): %s" %[enemies_in_range.size(), enemies_in_range])


func _process(delta: float) -> void:
	var input_dir := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	h_pivot.rotation.y -= input_dir.x * controller_sens * delta;
	v_pivot.rotation.x -= input_dir.y * controller_sens * delta;
	v_pivot.rotation.x = clamp(
		v_pivot.rotation.x,
		-PI/3,
		PI/4
	);


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (h_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_angle := atan2(-direction.x, -direction.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 5 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_lock_target_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		print("Enemy: %s in range" % body.name)


func _on_lock_target_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		print("Enemy: %s now out of range" % body.name)
