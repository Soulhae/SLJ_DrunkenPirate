extends "res://Scenes/Enemy/StateMachine/state.gd"
class_name BossAttack

@onready var enemy: CharacterBody3D = get_owner()
@onready var hitbox: Area3D = $"../../BOX/Hitbox"


func enter():
	choose_attack()


# Choose which attack to use.
func choose_attack():

	var attack = randi_range(0, 2)

	match attack:
		0:
			attack_0()

		1:
			attack_1()

		2:
			attack_2()


func attack_0():
	print("ATTACK 0")


func attack_1():
	print("ATTACK 1")


func attack_2():
	print("ATTACK 2")


func process(_delta: float):

	var bodies = hitbox.get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("player"):
			print("PLAYER IN RANGE")

	# Temporary for testing.
	Transitioned.emit(self, "bossrecovery")


func physics_process(delta: float):

	enemy.velocity.x = 0.0
	enemy.velocity.z = 0.0

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
