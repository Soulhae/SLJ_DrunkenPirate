class_name PlayerAttack
extends State

@onready var player: CharacterBody3D = get_owner()
@onready var anim_player: AnimationPlayer = player.get_node("AnimationPlayer")

var combo_step: int = 1
var can_chain: bool = false


func enter():
	combo_step = 1
	can_chain = false
	player.velocity.x = 0
	player.velocity.z = 0
	
	anim_player.play("attack_1")


func physics_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
	
	player.update_visuals_rotation(Vector3.ZERO, delta)
	
	if Input.is_action_just_pressed("attack") and can_chain:
		can_chain = false
		combo_step += 1
		
		if combo_step <= 3:
			anim_player.play("attack_" + str(combo_step))
			
	player.move_and_slide()


func allow_chain():
	can_chain = true


func finish_attack():
	Transitioned.emit(self, "PlayerIdle")
