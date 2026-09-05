class_name PlayerIdle
extends State


@onready var player: CharacterBody3D = get_owner()
@onready var label_3d: Label3D = player.get_node("Visuals/Label3D")


func enter():
	label_3d.text = "State: Idle"


func physics_process(delta: float) -> void:
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
		
	if Input.is_action_just_pressed("heal"):
		if player.Health < player.MaxHealth and player.heals_left > 0:
			Transitioned.emit(self, "playerheal")
		return
	
	var direction: Vector3 = player.get_camera_relative_input()
	
	if direction:
		Transitioned.emit(self, "PlayerMove")
		return
	
	player.velocity.x = move_toward(player.velocity.x, 0, player.move_speed)
	player.velocity.z = move_toward(player.velocity.z, 0, player.move_speed)
	
	player.update_visuals_rotation(Vector3.ZERO, delta)
	
	player.move_and_slide()
