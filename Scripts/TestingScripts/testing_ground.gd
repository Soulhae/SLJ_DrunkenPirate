extends Node

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")

	if player:
		get_tree().call_group("enemy","target_position",player.global_position)
