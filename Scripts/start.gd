extends Node3D

@onready var area3d: Area3D = $CAVE


func _on_cave_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
			get_tree().change_scene_to_file("res://Scenes/boss_fight.tscn")
