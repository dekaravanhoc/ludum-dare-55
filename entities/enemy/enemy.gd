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
	var number_of_enemies_to_place: int

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

	
	func get_strength() -> float:
		return health_mod + strength_mod + agility_mod + defense_mod + luck_mod



class EnemyTypes:
	const NUMBER_OF_ENEMY_TYPES: int = 2
	static func get_soldier() -> EnemyType:
		return EnemyType.new(
			"Soldier",
			preload("res://entities/enemy/meshes/soldier.tres"),
			preload("res://entities/enemy/assets/placeholder_icon.png"),
			0.25,
			0,
			-0.25,
			0,
			0,
			EnemyType.Position.FRONT
		)
	static func get_archer() -> EnemyType:
		return EnemyType.new(
			"Archer",
			preload("res://entities/enemy/meshes/archer.tres"),
			preload("res://entities/enemy/assets/placeholder_icon.png"),
			-0.25,
			0.25,
			0.25,
			-0.25,
			0,
			EnemyType.Position.BACK
		)
	
	static func get_random_enemy_type() -> EnemyType:
		match(randi_range(1, NUMBER_OF_ENEMY_TYPES)):
			1:
				return get_soldier()
			2:
				return get_archer()
			_:
				return get_soldier()


enum State { PREPARE, FIGHT, WIN, LOSS }

const army_grid_size: Vector2 = Vector2(1.5, 1.5)

@export var demon: Demon
@export var number_animation: NumberAnimation

@export var health: RangeStat
@export var strength: Stat
@export var agility: Stat
@export var defense: Stat
@export var luck: Stat

signal enemy_defeated

const base_cooldown: float = 3
const base_damage: int = 30
const base_crit_perc: float = .1
const base_crit_multiplier: float = 2.0

var cooldown: float = 0
var enemy_types: Array[EnemyType]
var current_state: State = State.PREPARE


func build_enemy(request: SummonRequest) -> void:
	enemy_types = request.enemy_types
	cooldown = _get_cooldown()
	_build_base_stats(request.exp_multiplier)
	print("Health: %d, Strengh: %d, Agility: %d, Defense: %d, Luck: %d" % [health.value, strength.value, agility.value, defense.value, luck.value])
	_modify_stats()
	print("Health: %d, Strengh: %d, Agility: %d, Defense: %d, Luck: %d" % [health.value, strength.value, agility.value, defense.value, luck.value])
	_place_meshes(roundi(request.exp_multiplier))

func start_combat() -> void:
	current_state = State.FIGHT

func hit(damage: int) -> int:
	var true_damage:int = _get_hit_damage(damage)
	health.value -= true_damage
	if(health.value  <= 0):
		current_state = State.LOSS
		enemy_defeated.emit()
	return true_damage
	
func _process(_delta: float) -> void:
	match current_state:
		State.FIGHT:
			cooldown -= _delta
			if cooldown < 0:
				_attack()
				cooldown = _get_cooldown()

func _attack() -> void:
	var demon_screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(
		demon.position
	)
	var is_crit: bool = _is_crit()
	var damage: int = _get_damage(is_crit)
	var damage_text: String = "Crit" if is_crit else ""
	var dealed_damage: int = demon.hit(damage)
	number_animation.add_damage(demon_screen_pos, dealed_damage, Color.LIGHT_GRAY, damage_text)


func _exit_tree() -> void:
	health.remove_all_mods()
	strength.remove_all_mods()
	agility.remove_all_mods()
	defense.remove_all_mods()
	luck.remove_all_mods()


func _place_meshes(muliplyer: int) -> void:
	enemy_types.sort_custom(func(a: EnemyType, b: EnemyType) -> bool: return a.position == EnemyType.Position.FRONT and b.position == EnemyType.Position.BACK) 
	var number_of_enemies: int = muliplyer
	var number_of_enemies_per_type: int = floori(number_of_enemies / float(enemy_types.size()))
	print("Number of Enemies: %d, Number of Enemies per Type: %d, Size: %d" % [number_of_enemies, number_of_enemies_per_type, enemy_types.size()])
	var number_of_enemies_x: int = ceil(sqrt(number_of_enemies))
	var number_of_enemies_y: int = number_of_enemies_x
	var starting_x_position: float = ((number_of_enemies_x - 1) / 2.0) * army_grid_size.x
	var current_placement_position: Vector3 = Vector3(starting_x_position, 0.5, 0)
	var current_enemy_type_index: int = 0
	for enemy: EnemyType in enemy_types:
		enemy.number_of_enemies_to_place = number_of_enemies_per_type 
		enemy.multimesh_instance.multimesh.instance_count = number_of_enemies_per_type
		add_child(enemy.multimesh_instance)
	if (number_of_enemies % enemy_types.size()) > 0:
		enemy_types[-1].number_of_enemies_to_place += 1
		enemy_types[-1].multimesh_instance.multimesh.instance_count += 1
	for y: int in number_of_enemies_y:
		for x: int in number_of_enemies_x:
			var enemy: EnemyType = enemy_types[current_enemy_type_index]
			enemy.multimesh_instance.multimesh.set_instance_transform(enemy.number_of_enemies_to_place - 1, Transform3D(Basis(), current_placement_position))
			current_placement_position.x -= army_grid_size.x
			enemy.number_of_enemies_to_place -= 1
			if enemy.number_of_enemies_to_place == 0:
				current_enemy_type_index += 1
				if current_enemy_type_index == enemy_types.size():
					return
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



func _build_base_stats(multiplyer: float) -> void:
	_base_stat_modify(health, multiplyer)
	health.value = health.max_value
	_base_stat_modify(strength, pow(10, 0.1) * multiplyer)
	_base_stat_modify(agility, pow(multiplyer, 0.5))
	_base_stat_modify(defense, 5 + pow(20, 0.1) * multiplyer)
	_base_stat_modify(luck, pow(multiplyer, 0.2))

func _base_stat_modify(stat: Stat, multiplyer: float) -> void:
	var mod: StatMod = StatMod.new()
	mod.type = Stat.MOD_TYPE.BaseMult
	mod.value = maxf(0, multiplyer - 1)
	stat.add_mod(mod)


func _get_hit_damage(damage: int) -> int:
	var hit_damage: int = roundi((damage - roundi(pow(defense.value / _get_cooldown(), 1.01))) / (base_crit_multiplier if _is_reduction_crit() else 1.0)) 
	return hit_damage

func _get_cooldown() -> float:
	return base_cooldown - pow(agility.value, 0.2) + 1


func _get_damage(is_crit: bool) -> int:
	return roundi(base_damage + pow(strength.value, 1.05) * randf_range(0.9, 1.1) * (base_crit_multiplier if is_crit else 1.0))


func _is_crit() -> bool:
	return randf_range(0.0, 1.0) <= (pow(luck.value * base_crit_perc, 0.5) - 0.2)

func _is_reduction_crit() -> bool:
	return randf_range(0.0, 1.0) <= (pow(luck.value * base_crit_perc, 0.5) - 0.2) / 2
