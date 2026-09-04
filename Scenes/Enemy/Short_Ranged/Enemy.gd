# SHORT-RANGE ENEMY
# General enemy controller.
# Ranged enemies can use the same setup with their own attack states.

extends CharacterBody3D

# Navigation system used by the enemy states.
@onready var nav = $NavigationAgent3D
@onready var label_3d: Label3D = $Label3D

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

	if Health <= 0:
		Health = 0
		is_dead = true
		print("ENEMY DIED")
		queue_free()
