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
@export var Health: int = 200

# Player target.
var target: Node3D


func _ready() -> void:
	label_3d.text = name


# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position
	
# WIP
# Makes the enemy jump.
func jump():
	if is_on_floor():
		velocity.y = JumpVelocity   #  not implemeted this yet...............

# use enemy.take_demage(amount) to damage the enemy.
func take_damage(amount: float):
	Health -= amount
	print("Enemy HP: ", Health)
