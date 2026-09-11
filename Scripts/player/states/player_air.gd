class_name PlayerAir
extends State

@onready var jump: AudioStreamPlayer = $"../../jump"

@onready var player: CharacterBody3D = get_owner()
@onready var label_3d: Label3D = player.get_node("Visuals/Label3D")

@onready var air_control: float = player.move_speed

@onready var sand_walk_sound: AudioStreamPlayer = $"../../Sand Walk Sound"
@onready var sand_roll_sound: AudioStreamPlayer = $"../../Sand Roll Sound"
@onready var water_walk_sound: AudioStreamPlayer = $"../../Water Walk Sound"
@onready var water_roll_sound: AudioStreamPlayer = $"../../Water Roll Sound"


func enter():
	label_3d.text = "State: Air"

	# Stop all movement sounds
	sand_walk_sound.stop()
	sand_roll_sound.stop()
	water_walk_sound.stop()
	water_roll_sound.stop()

	# Play jump
	jump.play()


func physics_process(delta: float):
	var direction: Vector3 = player.get_camera_relative_input()

	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		
		var target_vel_x = direction.x * player.move_speed
		var target_vel_z = direction.z * player.move_speed
		
		player.velocity.x = move_toward(player.velocity.x, target_vel_x, air_control)
		player.velocity.z = move_toward(player.velocity.z, target_vel_z, air_control)
		
		player.update_visuals_rotation(direction, delta)
	else:
		if direction:
			Transitioned.emit(self, "PlayerMove")
		else:
			Transitioned.emit(self, "PlayerIdle")
	
	player.move_and_slide()
