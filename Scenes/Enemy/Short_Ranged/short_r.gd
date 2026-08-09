# ENEMY SCRIPT
# Currently only follows the player.
extends CharacterBody3D
# Navigation system for finding a path to the player.
@onready var nav = $NavigationAgent3D


@export var WalkSpeed: float = 2.0
@export var RunSpeed: float = 6.0


# Receives the player's position.
func target_position(target):
	nav.target_position = target
