extends Control

@onready var click_sound = $click
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var options: Panel = $Options

func _ready() -> void:
	main_buttons.visible = true
	options.visible = false
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/intro.tscn")
	click_sound.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
	click_sound.play()

func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")
	click_sound.play()


func _on_option_pressed() -> void:
	main_buttons.visible = false
	options.visible = true
	click_sound.play()

func _on_back_pressed() -> void:
	main_buttons.visible = true
	options.visible = false
	click_sound.play()
