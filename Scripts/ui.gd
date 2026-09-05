extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var boss = get_tree().get_first_node_in_group("Boss")

@onready var player_health_bar: ProgressBar = $PlayerHealthBar
@onready var heal_label: Label = $HealLabel
@onready var clumsy_label: Label = $ClumsyLabel

@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var boss_name: Label = $BossName


func _ready() -> void:
	player_health_bar.max_value = player.MaxHealth
	player_health_bar.value = player.Health

	heal_label.text = "HEALS: %d / %d" % [player.heals_left, player.max_heals]
	clumsy_label.text = ""

	boss_health_bar.max_value = boss.Health
	boss_health_bar.value = boss.Health

	boss_health_bar.visible = false
	boss_name.visible = false


func _process(_delta: float) -> void:
	# PLAYER UI
	player_health_bar.value = player.Health
	heal_label.text = "HEALS: %d / %d" % [player.heals_left, player.max_heals]

	if player.drunk:
		clumsy_label.text = "CLUMSY: %.1f" % player.drunk_timer
	else:
		clumsy_label.text = ""


	# BOSS UI
	if boss != null:
		var distance = player.global_position.distance_to(boss.global_position)

		if distance <= boss.ChaseDistance:
			boss_health_bar.visible = true
			boss_name.visible = true
			boss_health_bar.value = boss.Health
		else:
			boss_health_bar.visible = false
			boss_name.visible = false
