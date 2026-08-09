# ENEMY SCRIPT
# Currently only follows the player.

extends CharacterBody3D

# Navigation system for finding a path to the player.
@onready var nav = $NavigationAgent3D

# Enemy movement speed.
var speed = 5.0

func _physics_process(delta):
	
	# Apply gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the next point on the navigation path.
	var next_location = nav.get_next_path_position()
	
	# Get the enemy's current position.
	var current_location = global_position
	
	# Calculate the direction towards the next point.
	var new_velocity = (next_location - current_location).normalized() * speed

	# Smoothly change to the new velocity.
	velocity = velocity.move_toward(new_velocity, 0.25)

	# Move the enemy.
	move_and_slide()


# Receives the player's position.
func target_position(target):
	nav.target_position = target
