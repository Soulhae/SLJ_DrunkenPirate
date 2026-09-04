class_name PlayerBlock
extends State

@onready var player: CharacterBody3D = get_owner()

var block_speed: float = 3.0

var parry_window: float = 0.25
var parry_timer: float = 0.0

func enter():
	parry_timer = parry_window
	print("BLOCKING - PARRY WINDOW")

func exit():
	print("STOP BLOCKING")

func physics_process(delta):
	if not Input.is_action_pressed("block"):
		Transitioned.emit(self, "PlayerIdle")
		return

	# Parry window
	if parry_timer > 0:
		parry_timer -= delta

	# Gravity
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	# Movement
	var direction: Vector3 = player.get_camera_relative_input()

	if direction:
		player.velocity.x = direction.x * block_speed
		player.velocity.z = direction.z * block_speed
	else:
		player.velocity.x = 0
		player.velocity.z = 0

	player.update_visuals_rotation(direction, delta)

	player.move_and_slide()
	
func is_parrying() -> bool:
	return parry_timer > 0.0
