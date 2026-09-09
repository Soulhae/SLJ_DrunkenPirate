extends Control

@onready var text_label: Label = $ColorRect/Label
@onready var next_button: Button = $ColorRect/button

var text_index := 0

var texts = [
	"I was just drinking with my crew...",
	"Ugh... my head hurts.",
	"Where the hell am I?",
	"Where's my crew?",
	"...At least I still have my drink and my weapons."
]


func _ready():
	text_label.text = texts[text_index]
	next_button.text = "NEXT"


func _on_button_pressed() -> void:
	if text_index < texts.size() - 1:
		text_index += 1
		
		# Add the next line instead of replacing the old text.
		text_label.text += "\n" + texts[text_index]
		
	else:
		next_button.text = "WAKE UP"
		next_button.pressed.disconnect(_on_button_pressed)
		next_button.pressed.connect(_wake_up)


func _wake_up():
	get_tree().change_scene_to_file("res://Scenes/cave.tscn")
