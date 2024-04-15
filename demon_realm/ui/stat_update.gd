class_name StatUpdate
extends HBoxContainer

@export var stat_for_update: Stat
@export var costs_to_use: int
@export var update_amount_to_use: int
@export var stat_name: Label
@export var stat_level: Label
@export var stat_update_amount: Label
@export var stat_costs: Label
@export var add_button: Button
@export var remove_button: Button
@export var save_button: Button

var demon_exp: Stat = preload("res://entities/demon/stats/demon_exp.tres")
var current_added_level: int = 0


func _ready() -> void:
	stat_name.text = stat_for_update.stat_name
	stat_level.text = "%4d" % stat_for_update.value
	stat_update_amount.text = "+%2d" % update_amount_to_use
	stat_costs.text = "-%5d K" % costs_to_use

	demon_exp.stat_modified.connect(_check_button_status)
	add_button.button_down.connect(_add_level)
	add_button.button_up.connect(_stop_add_level)
	remove_button.pressed.connect(_remove_level)
	save_button.pressed.connect(_save_stat)
	_check_button_status()

var add_is_pressed:bool
var pressed_timer:SceneTreeTimer

func _add_level() -> void:
	current_added_level += update_amount_to_use
	stat_level.text = "%4d" % (stat_for_update.value + current_added_level)
	demon_exp.value -= costs_to_use
	if(pressed_timer != null && pressed_timer.time_left > 0):
		pressed_timer.timeout.disconnect(_add_level_loop)
	add_is_pressed = true
	pressed_timer = get_tree().create_timer(0.5)
	pressed_timer.timeout.connect(_add_level_loop)
	await pressed_timer.timeout
	
func _stop_add_level()-> void:
	add_is_pressed = false

func _add_level_loop() -> void:
	while (add_is_pressed && demon_exp.value >= costs_to_use):
			current_added_level += update_amount_to_use
			stat_level.text = "%4d" % (stat_for_update.value + current_added_level)
			demon_exp.value -= costs_to_use
			await get_tree().create_timer(0.1).timeout
	

func _remove_level() -> void:
	current_added_level -= update_amount_to_use
	stat_level.text = "%4d" % (stat_for_update.value + current_added_level)
	demon_exp.value += costs_to_use


func _check_button_status() -> void:
	add_button.disabled = demon_exp.value < costs_to_use
	remove_button.disabled = current_added_level == 0


func _save_stat() -> void:
	if current_added_level == 0:
		return
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = current_added_level
	stat_for_update.add_mod(mod)
	if stat_for_update is RangeStat:
		stat_for_update.value = (stat_for_update as RangeStat).max_value
	current_added_level = 0
	_check_button_status()

