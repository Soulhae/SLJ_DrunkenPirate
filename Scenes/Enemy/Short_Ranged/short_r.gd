# SHORT-RANGE ENEMY
# General enemy controller.
# Ranged enemies can use the same setup with their own attack states.

extends CharacterBody3D

# Navigation system used by the enemy states.
@onready var nav = $NavigationAgent3D

# Enemy movement settings.
@export var ChaseDistance: float = 10.0
@export var WalkSpeed: float = 2.0
@export var RunSpeed: float = 4.0

# Player target.
var target: Node3D

# Receives the player's position from the main scene.
func target_position(target_position):
	nav.target_position = target_position
