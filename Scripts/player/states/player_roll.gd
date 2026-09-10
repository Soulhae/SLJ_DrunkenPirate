class_name PlayerRoll
extends State

@onready var sand_roll_sound: AudioStreamPlayer = $"../../Sand Roll Sound"
@onready var water_roll_sound: AudioStreamPlayer = $"../../Water Roll Sound"

@onready var player: CharacterBody3D = get_owner()
@onready var label_3d: Label3D = player.get_node("Visuals/Label3D")

var roll_direction: Vector3
var roll_time: float # used only for testing, it should transition to idle when roll animation ends
var breaking_factor: float = 7.5
const ROLLS_IN_SAND = preload("uid://cl0j2mog576wy")
const ROLLS_IN_WATER = preload("uid://chpb45ym3grij")
const SAND_FOOTSTEPS = preload("uid://dw1prbh003tom")
const WATER_FOOTSTEPS = preload("uid://d1y3p3ftuuhad")
func enter():
	if player.in_water:
		water_roll_sound.play()
	else:
		sand_roll_sound.play()
	#SAND_FOOTSTEPS.stop()
	#WATER_FOOTSTEPS.stop()
	label_3d.text = "State: Roll"
	
	roll_time = 0.5
	
	var input_dir: Vector3 = player.get_camera_relative_input()
	
	if input_dir:
		roll_direction = input_dir
	else:
		roll_direction = Vector3.FORWARD.rotated(Vector3.UP, player.visuals.rotation.y)
	
	player.velocity.x = roll_direction.x * player.move_speed * 1.5
	player.velocity.z = roll_direction.z * player.move_speed * 1.5


func physics_process(delta: float):

	if roll_time <= 0:
		Transitioned.emit(self, "PlayerIdle")
	
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
	
	roll_time -= delta
	
	player.velocity.x = move_toward(player.velocity.x, 0, breaking_factor * delta)
	player.velocity.z = move_toward(player.velocity.z, 0, breaking_factor * delta)
	
	player.update_visuals_rotation(roll_direction, delta)
	
	player.move_and_slide()
