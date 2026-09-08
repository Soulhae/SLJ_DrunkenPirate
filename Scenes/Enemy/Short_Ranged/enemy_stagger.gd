extends State
class_name EnemyStagger

@export var stagger_duration: float = 0.4

var enemy: CharacterBody3D
var timer: float = 0.0


func enter() -> void:
	enemy = owner as CharacterBody3D
	timer = stagger_duration

	if enemy:
		enemy.velocity = Vector3.ZERO

	print("ENEMY STAGGERED!")


func exit() -> void:
	pass


func process(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		Transitioned.emit(self, "enemychase")


func physics_process(_delta: float) -> void:
	if enemy:
		enemy.velocity = Vector3.ZERO
