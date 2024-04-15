class_name Combat
extends Node3D

signal combat_finished

@export var enemy: Enemy
@export var demon_position: Marker3D


func start_combat(request: SummonRequest, demon: Demon) -> void:
	enemy.build_enemy(request, demon)
	demon.build_demon(request, enemy)
	demon_position.add_child(demon)

	enemy.start_combat()
	demon.start_combat()
	demon.demon_defeated.connect(func() -> void: combat_finished.emit())
	demon.demon_won.connect(func() -> void: combat_finished.emit())

