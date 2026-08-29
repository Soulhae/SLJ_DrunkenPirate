extends CharacterBody3D

# Navigation system used by the Boss states.
@onready var nav = $NavigationAgent3D
@onready var Attack_radius: Area3D = $"Attack-Radius"
@onready var state_machine: StateMachine = $StateMachine

# Boss movement settings.
@export var AttackReach: float = 4.0
@export var WalkSpeed: float = 6.0
@export var RunSpeed: float = 10.0
@export var Health: int = 200
@export var ChaseDistance: float = 20.0

@export var water: MeshInstance3D
@export var ripple_distance: float = 1.5

var last_water_position: Vector3

# Player target.
var target: Node3D

# Prevents the death transition from being called multiple times.
var is_dead: bool = false


func _ready() -> void:
	last_water_position = global_position


# Check if the boss has died.
func _process(_delta):
	if Health <= 0 and not is_dead:
		is_dead = true
		
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
	
	print("SALT-EATEN HEALTH: ", Health)
	
	# Prevent health from going below zero.
	if Health <= 0:
		Health = 0


# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position
