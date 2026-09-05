class_name PlayerMove
extends State


@onready var player: CharacterBody3D = get_owner()
@onready var label_3d: Label3D = player.get_node("Visuals/Label3D")


func enter():
	label_3d.text = "State: Move"


func physics_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = player.JUMP_VELOCITY
		Transitioned.emit(self, "PlayerAir")
	
	if Input.is_action_just_pressed("roll") and player.is_on_floor():
		Transitioned.emit(self, "PlayerRoll")
		return
	
	if Input.is_action_just_pressed("attack") and player.is_on_floor():
		Transitioned.emit(self, "PlayerAttack")
		return
	if Input.is_action_just_pressed("block"):
		Transitioned.emit(self, "PlayerBlock")
		return
	
	var direction: Vector3 = player.get_camera_relative_input()
	
	if not direction:
		Transitioned.emit(self, "PlayerIdle")
		return
	

	if not direction:
		Transitioned.emit(self, "PlayerIdle")
		return

	if player.drunk:
		var drunk_offset := sin(Time.get_ticks_msec() * 0.006) * 0.7
		direction = direction.rotated(Vector3.UP, drunk_offset)

		var drunk_speed :float = player.move_speed * 0.75
		player.velocity.x = direction.x * drunk_speed
		player.velocity.z = direction.z * drunk_speed
	else:
		player.velocity.x = direction.x * player.move_speed
		player.velocity.z = direction.z * player.move_speed

	player.update_visuals_rotation(direction, delta)

	player.move_and_slide()
