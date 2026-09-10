extends CharacterBody3D

# Navigation system used by the Boss states.
@onready var nav = $NavigationAgent3D
@onready var Attack_radius: Area3D = $"Attack-Radius"
@onready var state_machine: StateMachine = $StateMachine
@export var damage_number_scene: PackedScene

@onready var mesh: MeshInstance3D = $boss/Armature/Skeleton3D/Rapier
var original_material: Material

# Boss movement settings.
@export var AttackReach: float = 5.0
@export var SlamReach: float = 8.0
@export var DiveReach: float = 20.0
@export var ChaseDistance: float = 30.0
@export var WalkSpeed: float = 10.0
@export var RunSpeed: float = 15.0

@export var Health: int = 200
@export var MaxHealth: int = 200

@onready var hurt = $hurt

@export var water: MeshInstance3D
@export var ripple_distance: float = 1.5

var last_water_position: Vector3

# Player target.
var target: Node3D

# Prevents the death transition from being called multiple times.
var is_dead: bool = false

# Boss fight timer.
var fight_time: float = 0.0


func _ready() -> void:
	Health = MaxHealth
	last_water_position = global_position

	# Find the player.
	target = get_tree().get_first_node_in_group("player")


# Check if the boss has died.
func _process(delta: float) -> void:
	if not is_dead:
		fight_time += delta

	if Health <= 0 and not is_dead:
		is_dead = true
		Health = 0

		# Save time taken to kill the boss.
		GameState.boss_fight_time = fight_time

		# Save heals used.
		if target != null:
			GameState.heals_used = target.max_heals - target.heals_left

		state_machine.current_state.Transitioned.emit(
			state_machine.current_state,
			"bossdeath"
		)


func _physics_process(_delta: float) -> void:
	if water == null:
		return

	if global_position.distance_to(last_water_position) > ripple_distance:
		water.create_ripple(global_position)
		last_water_position = global_position


# Deal damage to the boss and reduce its health.
func take_damage(damage: int):
	Health -= damage
	hit_flash()

	show_damage_number(damage,global_position + Vector3(-1, 1.5, 1.5))
	
	print("SALT-EATEN HEALTH: ", Health)

	hurt.play()

	if Health <= 0:
		Health = 0


# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position


func show_damage_number(amount: int, position: Vector3) -> void:
	var damage_number = damage_number_scene.instantiate()

	get_tree().current_scene.add_child(damage_number)

	damage_number.text_color = Color.WHITE
	damage_number.global_position = position
	damage_number.setup(-amount)


func stagger() -> void:
	if Health <= 0:
		return

	if state_machine.current_state.name == "BossStagger":
		return

	state_machine.current_state.Transitioned.emit(
		state_machine.current_state,
		"bossstagger"
	)

func hit_flash() -> void:
	var material = mesh.get_active_material(0).duplicate()
	
	if material is StandardMaterial3D:
		material.emission_enabled = true
		material.emission = Color.WHITE
		material.emission_energy_multiplier = 5.0
		
		mesh.set_surface_override_material(0, material)
		
		await get_tree().create_timer(0.1).timeout
		
		mesh.set_surface_override_material(0, original_material)
