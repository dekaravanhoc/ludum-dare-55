class_name DemonRealmUI
extends Control

signal combat_requested(request: SummonRequest)
signal rebirth_requested

@export var request_ui: RequestUI
@export var rebirth_button: Button
@export var blood_amount: Label

var blood: Stat = preload("res://entities/demon/stats/demon_blood_current.tres")


func _ready() -> void:
	blood_amount.text = "%d" % blood.value
	blood.stat_modified.connect(func() -> void: blood_amount.text = "%d" % blood.value)
	request_ui.contract_signed.connect(
		func(request: SummonRequest) -> void: combat_requested.emit(request)
	)
	rebirth_button.pressed.connect(func() -> void: rebirth_requested.emit())

