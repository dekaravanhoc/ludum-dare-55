class_name CombatUI
extends Control

@export var enemy_health: RangeStat
@export var demon_health: RangeStat

@export var fps_label: Label

@export var demon_health_bar: ProgressBar
@export var demon_health_label: Label
@export var demon_label_prefix: String

@export var enemy_health_bar: ProgressBar
@export var enemy_health_label: Label
@export var enemy_label_prefix: String


func _ready() -> void:
	var update_demon_health_bar: Callable = func() -> void:
		demon_health_bar.max_value = demon_health.max_value
		demon_health_bar.value = demon_health.value
		demon_health_label.text = "%s: %d" % [demon_label_prefix, int(demon_health.value)]
	demon_health.value_changed.connect(update_demon_health_bar)
	update_demon_health_bar.call()
	
	var update_enemy_health_bar: Callable = func() -> void:
		enemy_health_bar.max_value = enemy_health.max_value
		enemy_health_bar.value = enemy_health.value
		enemy_health_label.text = "%s: %d" % [enemy_label_prefix, int(enemy_health.value)]
	enemy_health.value_changed.connect(update_enemy_health_bar)
	update_enemy_health_bar.call()

	if not OS.is_debug_build():
		fps_label.hide()
		set_process(false)

func _process(delta: float) -> void:
	fps_label.text = str(round(1 / delta))

