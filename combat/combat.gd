class_name Combat
extends Node3D

@export var enemy: Enemy
@export var demon: Demon


func _ready() -> void:
	start_combat([Enemy.EnemyTypes.Soldier, Enemy.EnemyTypes.Archer], 100000)


func start_combat(enemy_types: Array[Enemy.EnemyType], experience: int) -> void:
	enemy.build_enemy(enemy_types, experience)

