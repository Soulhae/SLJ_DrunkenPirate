class_name PlayerAttack
extends State

@onready var player: CharacterBody3D = get_owner()
@onready var anim_player: AnimationPlayer = player.get_node("AnimationPlayer")
@onready var attack_hitbox: Area3D = player.get_node("AttackHitbox")

@export var attack_damage: int = 20

var combo_step: int = 1
var can_chain: bool = false


func enter():
	combo_step = 1
	can_chain = false

	player.velocity.x = 0
	player.velocity.z = 0

	anim_player.play("attack_1")

	deal_attack_damage()

func physics_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
		return

	player.update_visuals_rotation(Vector3.ZERO, delta)

	if Input.is_action_just_pressed("attack") and can_chain:
		can_chain = false
		combo_step += 1

		if combo_step <= 3:
			anim_player.play("attack_" + str(combo_step))

	player.move_and_slide()


func deal_attack_damage():
	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(attack_damage)
				print("PLAYER HIT: ", body.name)


func allow_chain():
	can_chain = true


func finish_attack():
	Transitioned.emit(self, "PlayerIdle")
