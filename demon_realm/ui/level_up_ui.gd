class_name LevelUPUI
extends Control

@export var current_exp: Label

var demon_exp: Stat = preload("res://entities/demon/stats/demon_exp.tres")


func _ready() -> void:
	demon_exp.stat_modified.connect(_update_exp_label)
	_update_exp_label()


func _update_exp_label() -> void:
	current_exp.text = "%d" % demon_exp.value

