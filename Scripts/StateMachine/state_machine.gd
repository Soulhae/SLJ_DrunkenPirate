extends Node
class_name StateMachine

# State used when the machine starts.
@export var InitialState: State = null

# Currently active state.
var current_state: State = null

# Stores all states under this node.
var states: Dictionary = {}

func _ready() -> void:
	# Find and register all child states.
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transitioned)

	# Start with the initial state.
	if InitialState:
		current_state = InitialState
		InitialState.enter()


# Update the current state.
func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


# Physics update for the current state.
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


# Handles state changes.
func on_child_transitioned(state, new_state_name):

	if state != current_state:
		return

	var new_state = states[new_state_name.to_lower()]


	# Exit the old state.
	if current_state:
		current_state.exit()

	# Enter the new state.
	new_state.enter()
	current_state = new_state
