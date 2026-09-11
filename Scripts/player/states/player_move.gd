class_name PlayerMove
extends State

@onready var sand_walk_sound: AudioStreamPlayer = $"../../Sand Walk Sound"
@onready var water_walk_sound: AudioStreamPlayer = $"../../Water Walk Sound"

@onready var player: CharacterBody3D = get_owner()
@onready var label_3d: Label3D = player.get_node("Visuals/Label3D")


func enter():
	label_3d.text = "State: Move"

	if player.in_water:
		sand_walk_sound.stop()
		water_walk_sound.play()
	else:
		water_walk_sound.stop()
		sand_walk_sound.play()


func physics_process(delta: float):

	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
		return

	if Input.is_action_just_pressed("jump"):
		player.velocity.y = player.JUMP_VELOCITY
		Transitioned.emit(self, "PlayerAir")
		return

	if Input.is_action_just_pressed("roll"):
		Transitioned.emit(self, "PlayerRoll")
		return

	if Input.is_action_just_pressed("attack"):
		Transitioned.emit(self, "PlayerAttack")
		return

	if Input.is_action_just_pressed("block"):
		Transitioned.emit(self, "PlayerBlock")
		return

	var direction: Vector3 = player.get_camera_relative_input()

	if not direction:
		sand_walk_sound.stop()
		water_walk_sound.stop()
		Transitioned.emit(self, "PlayerIdle")
		return

	# Change footstep sound if player enters/leaves water
	if player.in_water:
		sand_walk_sound.stop()
		if not water_walk_sound.playing:
			water_walk_sound.play()
	else:
		water_walk_sound.stop()
		if not sand_walk_sound.playing:
			sand_walk_sound.play()

	if player.drunk:
		var drunk_offset := sin(Time.get_ticks_msec() * 0.006) * 0.7
		direction = direction.rotated(Vector3.UP, drunk_offset)

		var drunk_speed: float = player.move_speed * 0.75
		player.velocity.x = direction.x * drunk_speed
		player.velocity.z = direction.z * drunk_speed
	else:
		player.velocity.x = direction.x * player.move_speed
		player.velocity.z = direction.z * player.move_speed

	player.update_visuals_rotation(direction, delta)
	player.move_and_slide()
