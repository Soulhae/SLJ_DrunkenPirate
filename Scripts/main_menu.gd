extends Control

@onready var click_sound = $click

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/boss_fight.tscn")
	click_sound.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
	click_sound.play()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
	click_sound.play()
