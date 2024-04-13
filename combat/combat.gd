class_name Combat
extends Node3D

@export var enemy: Enemy
@export var demon: Demon

const base_cooldown: float = 1
const base_damage: float = 100
const base_crit_perc: float = .1
const base_crit_multiplier: float = 1.5

static var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	start_combat([Enemy.EnemyTypes.Soldier, Enemy.EnemyTypes.Archer], 100000)

func start_combat(enemy_types: Array[Enemy.EnemyType], experience: int) -> void:
	enemy.build_enemy(enemy_types, experience)

static func getHitDamage(_damage: float, _defense: float)->float:
	return _damage / _defense

static func getHealth()->float:
	return 100

static func getCooldown(_agility: float)->float:
	return base_cooldown / _agility

static func getDamage(_strength: float, _isCrit: bool)->float:
	var crit_multiplier:float = base_crit_multiplier if _isCrit else 1
	return base_damage * _strength * rng.randf_range(0.9, 1.1) * crit_multiplier
	
static func getCrit(_luck: float)->bool:
	return rng.randf_range(0, 1 + _luck) > (1-base_crit_perc)
