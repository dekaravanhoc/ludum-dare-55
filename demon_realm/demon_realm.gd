class_name DemonRealm
extends Node3D

signal combat_requested(request: SummonRequest)
signal rebirth_requested

@export var demon: Demon

@export var ui: DemonRealmUI


func _ready() -> void:
	ui.combat_requested.connect(_combat_requested)
	ui.rebirth_requested.connect(_rebirth_requested)


func _combat_requested(request: SummonRequest) -> void:
	ui.hide()
	combat_requested.emit(request)


func _rebirth_requested() -> void:
	demon.rebirth()
	rebirth_requested.emit()

