extends State
class_name BossDeath

@onready var enemy: CharacterBody3D = get_owner()

var death_timer: float = 2.0
@onready var death = $death

func enter():
	print("SALT-EATEN DIED")
	death.play()
	enemy.velocity = Vector3.ZERO
	death_timer = 2.0


func process(delta):
	death_timer -= delta
	
	if death_timer <= 0.0:
		get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")


func physics_process(delta):
	enemy.velocity = Vector3.ZERO

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
