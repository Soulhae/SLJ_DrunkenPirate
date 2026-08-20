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
	
	var direction: Vector3 = player.get_camera_relative_input()
	
	if not direction:
		Transitioned.emit(self, "PlayerIdle")
		return
	
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	
	player.update_visuals_rotation(direction, delta)
	
	player.move_and_slide()
