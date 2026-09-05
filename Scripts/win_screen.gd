extends Control

@onready var click_sound = $click

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	click_sound.play()
