class_name Combat
extends Node3D

signal combat_finished

@export var enemy: Enemy
@export var demon: Demon


func start_combat(request: SummonRequest) -> void:
	enemy.build_enemy(request)
	demon.start_combat(request)
	demon.demon_defeated.connect(func() -> void: combat_finished.emit())
	demon.demon_won.connect(func() -> void: combat_finished.emit())

