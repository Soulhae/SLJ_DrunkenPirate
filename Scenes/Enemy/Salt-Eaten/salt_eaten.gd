extends CharacterBody3D

@onready var label_3d: Label3D = $Label3D

# Navigation system used by the Boss states.
@onready var nav = $NavigationAgent3D


#Boss movement settings.
@export var AttackReach: float = 4.0
@export var WalkSpeed: float = 6.0
@export var RunSpeed: float = 10
@export var Health: int = 200
@export var ChaseDistance: float = 20.0


# Player target.
var target: Node3D

# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position
	
	
