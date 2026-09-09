extends Control

@onready var boss_health_label: Label = $Background/stats/BossHPLabel
@onready var heals_used_label: Label = $Background/stats/HealsLabel
@onready var click: AudioStreamPlayer = $click


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	boss_health_label.text = "BOSS HP: %d / %d" % [
		GameState.boss_remaining_health,
		GameState.boss_max_health
	]

	heals_used_label.text = "HEALS USED: %d" % GameState.heals_used


func _on_back_pressed() -> void:
		get_tree().change_scene_to_file("res://Scenes/boss_fight.tscn")
		click.play()

func _on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
