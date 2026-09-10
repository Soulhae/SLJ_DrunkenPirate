extends State
class_name BossDeath

@onready var enemy: CharacterBody3D = get_owner()
@onready var death = $"../../death"
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"

@export var death_time: float = 2.0


func enter() -> void:
	animation_player.play("death")
	print("SALT-EATEN DIED")

	death.play()

	enemy.velocity = Vector3.ZERO


func process(delta: float) -> void:
	death_time -= delta

	if death_time <= 0.0:
		get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")


func physics_process(delta: float) -> void:
	enemy.velocity = Vector3.ZERO

	if not enemy.is_on_floor():
		enemy.velocity += enemy.get_gravity() * delta

	enemy.move_and_slide()
