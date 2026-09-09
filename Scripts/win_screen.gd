extends Control

@onready var click_sound = $click
@onready var heals_label_2: Label = $HealsLabel2
@onready var time: Label = $time


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	heals_label_2.text = "HEALS USED: %d" % GameState.heals_used

	var total_seconds := int(GameState.boss_fight_time)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	time.text = "TIME: %02d:%02d" % [minutes, seconds]


func _on_button_pressed() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
