# SHORT-RANGE ENEMY
# General enemy controller.
# Ranged enemies can use the same setup with their own attack states.

extends CharacterBody3D

# Navigation system used by the enemy states.
@onready var nav = $NavigationAgent3D
@onready var label_3d: Label3D = $Label3D
@export var damage_number_scene: PackedScene
@onready var hurt = $hurt
@onready var mesh: MeshInstance3D = $body
var original_material: Material
# Enemy movement settings.
@export var JumpVelocity: float = 5.0
@export var JumpDistance: float = 3.0
@export var AttackReach: float = 2.0
@export var ChaseDistance: float = 10.0
@export var WalkSpeed: float = 3.0
@export var RunSpeed: float = 8.5
@export var Health: int = 50

@export var water: MeshInstance3D
@export var ripple_distance: float = 1.0

var last_water_position: Vector3

# Player target.
var target: Node3D


func _ready() -> void:
	last_water_position = global_position
	label_3d.text = name
	original_material = mesh.get_active_material(0)


# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position


func _physics_process(_delta: float) -> void:
	if water == null:
		return

	if global_position.distance_to(last_water_position) > ripple_distance:
		water.create_ripple(global_position)
		last_water_position = global_position


# use enemy.take_demage(amount) to damage the enemy

var is_dead := false

func take_damage(damage: int) -> void:
	if is_dead:
		return

	Health -= damage
	print("Enemy HP: ", Health)
	show_damage_number(damage, global_position + Vector3(0, 1.5, 0))
	hit_flash()

	if Health <= 0:
		Health = 0
		is_dead = true
		print("ENEMY DIED")
		queue_free()

func show_damage_number(amount: int, position: Vector3) -> void:
	var damage_number = damage_number_scene.instantiate()

	get_tree().current_scene.add_child(damage_number)
	damage_number.text_color = Color.WHITE
	damage_number.global_position = position
	damage_number.setup(-amount)

func hit_flash() -> void:
	var material = mesh.get_active_material(0).duplicate()
	
	if material is StandardMaterial3D:
		material.emission_enabled = true
		material.emission = Color.WHITE
		material.emission_energy_multiplier = 5.0
		
		mesh.set_surface_override_material(0, material)
		
		await get_tree().create_timer(0.1).timeout
		
		mesh.set_surface_override_material(0, original_material)
func stagger() -> void:
	if is_dead:
		return

	var state_machine = $StateMachine

	if state_machine.current_state.name == "EnemyStagger":
		return

	state_machine.current_state.Transitioned.emit(
		state_machine.current_state,
		"enemystagger"
	)
