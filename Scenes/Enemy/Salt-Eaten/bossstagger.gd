extends State
class_name BossStagger

@export var stagger_duration: float = 0.6

@onready var boss_stagger: GPUParticles3D = $"../../BOSS STAGGER"
@onready var enemy: CharacterBody3D = get_owner()
@onready var animation_player: AnimationPlayer = $"../../boss/AnimationPlayer"

var timer: float = 0.0


func enter() -> void:
	animation_player.stop()
	enemy.velocity = Vector3.ZERO
	timer = stagger_duration

	# PLAY STAGGER EFFECT
	if is_instance_valid(boss_stagger):
		boss_stagger.restart()
		boss_stagger.emitting = true

	print("BOSS STAGGERED!")


func process(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		Transitioned.emit(self, "bosschase")


func physics_process(_delta: float) -> void:
	enemy.velocity = Vector3.ZERO


func exit() -> void:
	enemy.velocity = Vector3.ZERO
