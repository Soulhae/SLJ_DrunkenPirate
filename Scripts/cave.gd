extends Area3D

@onready var player = get_tree().get_first_node_in_group("player")

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		get_tree().change_scene_to_file("res://Scenes/boss_fight.tscn")
