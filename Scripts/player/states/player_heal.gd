class_name PlayerHeal
extends State

@onready var player: CharacterBody3D = get_owner()

@export var heal_amount: int = 50
@export var heal_time: float = 1.0
@export var drunk_time: float = 6.0

var healing: bool = false
var heal_finished: bool = false


func enter() -> void:
	# Can't heal at full health
	if player.Health >= player.MaxHealth:
		Transitioned.emit(self, "playeridle")
		return

	# No heals left
	if player.heals_left <= 0:
		Transitioned.emit(self, "playeridle")
		return

	healing = true
	heal_finished = false

	# Stop the player while drinking
	player.velocity.x = 0
	player.velocity.z = 0

	heal()


func heal() -> void:
	print("DRINKING HEAL...")

	await get_tree().create_timer(heal_time).timeout

	if not is_inside_tree():
		return

	# Heal
	player.Health = min(
		player.Health + heal_amount,
		player.MaxHealth
	)

	# Use one heal
	player.heals_left -= 1

	# Become drunk
	player.drunk = true
	player.drunk_timer = drunk_time

	print("HEALED! PLAYER HEALTH: ", player.Health)
	print("HEALS LEFT: ", player.heals_left)
	print("PLAYER IS DRUNK!")

	healing = false
	heal_finished = true


func process(_delta: float) -> void:
	if heal_finished:
		heal_finished = false
	Transitioned.emit(self, "playeridle")


func physics_process(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	# Don't move while drinking
	player.velocity.x = 0
	player.velocity.z = 0

	player.move_and_slide()


func exit() -> void:
	healing = false
