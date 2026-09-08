extends State
class_name BossStagger

@export var stagger_duration: float = 0.6

var boss: CharacterBody3D
var timer: float = 0.0


func enter() -> void:
	boss = owner as CharacterBody3D
	timer = stagger_duration

	if boss:
		boss.velocity = Vector3.ZERO

	print("BOSS STAGGERED!")


func exit() -> void:
	pass


func process(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		Transitioned.emit(self, "bosschase")


func physics_process(_delta: float) -> void:
	if boss:
		boss.velocity = Vector3.ZERO
