class_name GrowthOption
extends MarginContainer

@export var demon_scene: PackedScene
@export var name_label: Label
@export var blood_cost_label: Label
@export var button: Button
@export var demon_show_viewport: SubViewport
@export var blood_cost: int

var blood: Stat = preload("res://entities/demon/stats/demon_blood_current.tres")


func add_to_button_group(button_group: ButtonGroup) -> void:
	button.button_group = button_group


func _ready() -> void:
	var demon: Demon = demon_scene.instantiate()
	demon_show_viewport.add_child(demon)
	demon.show_growth()
	name_label.text = demon.demon_name
	blood_cost_label.text = "Blood Cost: %4d" % blood_cost
	button.disabled = blood_cost > blood.value
	blood.stat_modified.connect(func() -> void: button.disabled = blood_cost > blood.value)

