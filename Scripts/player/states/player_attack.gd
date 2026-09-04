class_name PlayerAttack
extends State

@onready var player: CharacterBody3D = get_owner()
@onready var anim_player: AnimationPlayer = player.get_node("AnimationPlayer")
@onready var attack_hitbox: Area3D = player.get_node("AttackHitbox")

@export var attack_damage_1: int = 10
@export var attack_damage_2: int = 15
@export var attack_damage_3: int = 20

var combo_step: int = 1
var can_chain: bool = false
var attack_pending: bool = false


func enter():
	combo_step = 1
	can_chain = false
	attack_pending = true

	player.velocity.x = 0
	player.velocity.z = 0

	anim_player.play("attack_1")


func physics_process(delta: float):
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
		Transitioned.emit(self, "PlayerAir")
		return

	player.update_visuals_rotation(Vector3.ZERO, delta)

	# Move first, then check the hitbox.
	player.move_and_slide()

	# Check damage after physics has updated the hitbox.
	if attack_pending:
		attack_pending = false
		deal_attack_damage()

	if Input.is_action_just_pressed("attack") and can_chain:
		can_chain = false
		combo_step += 1

		if combo_step <= 3:
			anim_player.play("attack_" + str(combo_step))
			attack_pending = true


func deal_attack_damage():
	var damage := 0

	match combo_step:
		1:
			damage = attack_damage_1
		2:
			damage = attack_damage_2
		3:
			damage = attack_damage_3

	for body in attack_hitbox.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("PLAYER HIT: ", body.name, " DAMAGE: ", damage)


func allow_chain():
	can_chain = true


func finish_attack():
	Transitioned.emit(self, "PlayerIdle")
