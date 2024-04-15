class_name GrowthUI
extends PanelContainer

signal growth_selected(demon_scene: PackedScene)

@export var growth_button: Button
@export var growth_container: VBoxContainer
@export var blood_amount: Label

var blood: Stat = preload("res://entities/demon/stats/demon_blood_current.tres")
var growth_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	blood_amount.text = "Current Blood: %d" % blood.value
	blood.stat_modified.connect(
		func() -> void: 
			blood_amount.text = "Current Blood: %d" % blood.value)
	growth_button_group.allow_unpress = true
	growth_button.disabled = true
	growth_button_group.pressed.connect(
		func(_button: BaseButton) -> void:
			growth_button.disabled = not growth_button_group.get_pressed_button() is Button
			)
	for growth_option: GrowthOption in growth_container.get_children():
		growth_option.add_to_button_group(growth_button_group)
	
	growth_button.pressed.connect(_grow)
	visibility_changed.connect(func() -> void:
		var button: Button = growth_button_group.get_pressed_button()
		if button is Button: button.button_pressed = false
		growth_button.disabled = true
		)

func _grow() -> void:
	var grow_option: GrowthOption = growth_button_group.get_pressed_button().get_parent()
	blood.value -= grow_option.blood_cost
	growth_button.disabled = true
	growth_selected.emit(grow_option.demon_scene)
	grow_option.queue_free()
