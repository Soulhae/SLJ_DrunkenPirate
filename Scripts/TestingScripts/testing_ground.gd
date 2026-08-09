# Sends the player's position to all enemies.
extends Node

# Reference to the test player.
@onready var target = $PlayerTEST

func _process(delta):
	# Tell every enemy where the player is.
	get_tree().call_group("enemy", "target_position", target.global_position)
