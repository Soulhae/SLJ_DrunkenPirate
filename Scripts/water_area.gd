extends Area3D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.enter_water()

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.exit_water()
