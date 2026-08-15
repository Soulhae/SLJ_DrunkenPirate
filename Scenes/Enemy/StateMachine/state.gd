extends Node
class_name State

# Sent when this state wants to switch to another state.
signal Transitioned(state: State, new_state_name: String)

# Called when entering this state.
func enter():
	pass

# Called when leaving this state.
func exit():
	pass

# Regular frame update.
func process(_delta: float):
	pass

# Physics update.
func physics_process(_delta: float):
	pass
