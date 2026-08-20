extends State
class_name BossDeath

# Reference to the enemy.
@onready var enemy: CharacterBody3D = get_owner()


# Set up the death state.
func enter():
	print("SALT-EATEN DIED")
	enemy.velocity = Vector3.ZERO


# No processing is needed after death for now.
func process(_delta: float):
	pass


# Keep the boss stopped after death.
func physics_process(delta: float):
	enemy.velocity = Vector3.ZERO

	# Apply gravity.
	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
