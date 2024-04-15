class_name DemonRealm
extends Node3D

signal combat_requested(request: SummonRequest)
signal rebirth_requested

@export var demon_position: Marker3D

@export var ui: DemonRealmUI

var demon: Demon


func _ready() -> void:
	ui.combat_requested.connect(_combat_requested)
	ui.rebirth_requested.connect(_rebirth_requested)
	ui.hide()


func add_demon(demon_to_use: Demon, with_animation: bool = true) -> void:
	demon = demon_to_use
	demon_position.add_child(demon)
	if with_animation:
		await demon.summon()
	ui.show()


func _combat_requested(request: SummonRequest) -> void:
	ui.hide()
	combat_requested.emit(request)


func _rebirth_requested() -> void:
	rebirth_requested.emit()

