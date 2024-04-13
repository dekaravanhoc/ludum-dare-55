class_name Enemy
extends Node3D


class EnemyType:
	extends RefCounted

	enum Position { FRONT, BACK }

	var name: String
	var icon: Texture2D
	var health_mod: float
	var strength_mod: float
	var agility_mod: float
	var defense_mod: float
	var luck_mod: float
	var position: Position

	var multimesh_instance: MultiMeshInstance3D = MultiMeshInstance3D.new()

	func _init(
		enemy_name: String,
		enemy_mesh: Mesh,
		icon_to_use: Texture2D,
		health_mod_to_use: float,
		strength_mod_to_use: float,
		agility_mod_to_use: float,
		defense_mod_to_use: float,
		luck_mod_to_use: float,
		position_to_use: Position
	) -> void:
		name = enemy_name
		multimesh_instance.multimesh = MultiMesh.new()
		multimesh_instance.multimesh.mesh = enemy_mesh
		multimesh_instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		icon = icon_to_use
		health_mod = health_mod_to_use
		strength_mod = strength_mod_to_use
		agility_mod = agility_mod_to_use
		defense_mod = defense_mod_to_use
		luck_mod = luck_mod_to_use
		position = position_to_use


static var EnemyTypes: Dictionary = {
	Soldier =
	EnemyType.new(
		"Soldier",
		preload("res://entities/enemy/meshes/soldier.tres"),
		preload("res://entities/enemy/assets/placeholder_icon.png"),
		0.5,
		0,
		0,
		0,
		0,
		EnemyType.Position.FRONT
	),
	Archer =
	EnemyType.new(
		"Archer",
		preload("res://entities/enemy/meshes/archer.tres"),
		preload("res://entities/enemy/assets/placeholder_icon.png"),
		0,
		0.25,
		0.5,
		-0.25,
		0,
		EnemyType.Position.BACK
	)
}

enum State { PREPARE, FIGHT, WIN, LOSS }

const army_grid_size: Vector2 = Vector2(1.5, 1.5)

@export var health: RangeStat
@export var strength: Stat
@export var agility: Stat
@export var defense: Stat
@export var luck: Stat

var enemy_types: Array[EnemyType]
var current_state: State = State.PREPARE


func build_enemy(enemy_types_to_use: Array[EnemyType], experience: int) -> void:
	enemy_types = enemy_types_to_use
	_build_base_stats(experience)
	_modify_stats()
	_place_meshes(experience)


func hit(damage: int) -> void:
	pass


func _place_meshes(experience: int) -> void:
	enemy_types.sort_custom(func(a: EnemyType, b: EnemyType) -> bool: return a.position == EnemyType.Position.FRONT and b.position == EnemyType.Position.BACK) 
	var number_of_enemies: int = maxi(int(experience / 100.0), 1)
	print("Number of Enemies: %d" % number_of_enemies)
	var number_of_enemies_x: int = ceil(sqrt(number_of_enemies))
	var number_of_enemies_y: int = number_of_enemies_x
	var starting_x_position: float = ((number_of_enemies_x - 1) / 2.0) * army_grid_size.x
	var current_placement_position: Vector3 = Vector3(starting_x_position, 0.5, 0)
	var current_enemy_type_index: int = 0
	var number_till_next_type: int = ceil(number_of_enemies / float(enemy_types.size()))
	for enemy: EnemyType in enemy_types:
		enemy.multimesh_instance.multimesh.instance_count = number_till_next_type
		add_child(enemy.multimesh_instance)
	for y: int in number_of_enemies_y:
		for x: int in number_of_enemies_x:
			var enemy: EnemyType = enemy_types[current_enemy_type_index]
			enemy.multimesh_instance.multimesh.set_instance_transform(number_till_next_type - 1, Transform3D(Basis(), current_placement_position))
			current_placement_position.x -= army_grid_size.x
			number_till_next_type -= 1
			if number_till_next_type == 0:
				current_enemy_type_index += 1
				if current_enemy_type_index == enemy_types.size():
					return
				number_till_next_type = ceil(number_of_enemies / float(enemy_types.size()))
		current_placement_position.z -= army_grid_size.y
		current_placement_position.x = starting_x_position
	

func _modify_stats() -> void:
	var stat_partial: float = 1.0 / enemy_types.size()
	var hp_mod: StatMod = StatMod.new()
	hp_mod.type = Stat.MOD_TYPE.Mult
	var strength_mod: StatMod = StatMod.new()
	strength_mod.type = Stat.MOD_TYPE.Mult
	var agility_mod: StatMod = StatMod.new()
	agility_mod.type = Stat.MOD_TYPE.Mult
	var defense_mod: StatMod = StatMod.new()
	defense_mod.type = Stat.MOD_TYPE.Mult
	var luck_mod: StatMod = StatMod.new()
	luck_mod.type = Stat.MOD_TYPE.Mult

	for enemy: EnemyType in enemy_types:
		hp_mod.value += enemy.health_mod * stat_partial
		strength_mod.value += enemy.strength_mod * stat_partial
		agility_mod.value += enemy.agility_mod * stat_partial
		defense_mod.value += enemy.defense_mod * stat_partial
		luck_mod.value += enemy.luck_mod * stat_partial
	
	health.add_mod(hp_mod)
	health.value = health.max_value
	strength.add_mod(strength_mod)
	agility.add_mod(agility_mod)
	defense.add_mod(defense_mod)
	luck.add_mod(luck_mod)

	print(health.value, strength.value, agility.value, defense.value, luck.value)


func _build_base_stats(experience: int) -> void:
	health.add_mod(_get_health_mod_by_exp(health.max_value, experience))
	health.value = health.max_value
	strength.add_mod(_get_strength_mod_by_exp(strength.value, experience))
	agility.add_mod(_get_agility_mod_by_exp(agility.value, experience))
	defense.add_mod(_get_defense_mod_by_exp(defense.value, experience))
	luck.add_mod(_get_luck_mod_by_exp(luck.value, experience))


func _get_health_mod_by_exp(health_to_modify: float, experience: int) -> StatMod:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = (maxf(1.0, experience / 100.0) - 1.0) * health_to_modify
	return mod


func _get_strength_mod_by_exp(strength_to_modify: float, experience: int) -> StatMod:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = (maxf(1.0, experience / 100.0) - 1.0) * strength_to_modify
	return mod


func _get_agility_mod_by_exp(agility_to_modify: float, experience: int) -> StatMod:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = (maxf(1.0, experience / 100.0) - 1.0) * agility_to_modify
	return mod


func _get_defense_mod_by_exp(defense_to_modify: float, experience: int) -> StatMod:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = (maxf(1.0, experience / 100.0) - 1.0) * defense_to_modify
	return mod


func _get_luck_mod_by_exp(luck_to_modify: float, experience: int) -> StatMod:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseAdd
	mod.value = (maxf(1.0, experience / 100.0) - 1.0) * luck_to_modify
	return mod

