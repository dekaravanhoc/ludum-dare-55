class_name DemonRealmUI
extends Control

signal combat_requested(request: SummonRequest)
signal rebirth_requested

@export var request_ui: RequestUI
@export var rebirth_button: Button


func _ready() -> void:
	request_ui.contract_signed.connect(
		func(request: SummonRequest) -> void: combat_requested.emit(request)
	)
	rebirth_button.pressed.connect(func() -> void: rebirth_requested.emit())

