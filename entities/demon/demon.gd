class_name Demon
extends Node3D

@export var enemy: Enemy
@export var number_animation: NumberAnimation

@export var blood_current: Stat
@export var blood_earned: Stat
@export var experience_current: Stat
@export var reputation: Stat
@export var health: RangeStat
@export var defense: Stat
@export var luck: Stat
@export var strength: Stat
@export var agility: Stat

signal demon_defeated
signal demon_won

const base_cooldown: float = 2
const base_damage: int = 30
const base_crit_perc: float = .1
const base_crit_multiplier: float = 2.0

var cooldown: float = 0
var currentState: DemonState = DemonState.DEMONREALM

enum DemonState { FIGHT, LOSS, WIN, DEMONREALM }


func start_combat(request: SummonRequest) -> void:
	blood_current.value += request.blood_gain
	currentState = DemonState.FIGHT
	cooldown = _get_cooldown()
	health.value = health.max_value
	if enemy:
		enemy.enemy_defeated.connect(
			func() -> void: 
				currentState = DemonState.WIN
				experience_current.value += request.exp_gain
				demon_won.emit()
				)


func _process(_delta: float) -> void:
	match currentState:
		DemonState.FIGHT:
			_fight(_delta)
		DemonState.LOSS:
			pass
		DemonState.WIN:
			pass
		DemonState.DEMONREALM:
			pass


func hit(_damage: int) -> int:
	var dealed_damage: int = _get_hit_damage(_damage)
	health.value -= dealed_damage
	if health.value <= 0:
		currentState = DemonState.LOSS
		demon_defeated.emit()
	return dealed_damage


func _fight(_delta: float) -> void:
	cooldown -= _delta
	if cooldown < 0:
		_attack()
		cooldown = _get_cooldown()


func _attack() -> void:
	var enemy_screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(
		enemy.position
	)
	var is_crit: bool = _is_crit()
	var damage: int = _get_damage(is_crit)
	var damage_text: String = "Crit" if is_crit else ""
	# add skill damage and set skill name/color
	var dealed_damage: int = enemy.hit(damage)
	number_animation.add_damage(enemy_screen_pos, dealed_damage, Color.DARK_RED, damage_text)

func _get_hit_damage(damage: int) -> int:
	return roundi((damage - roundi(pow(defense.value / _get_cooldown(), 1.5))) / (base_crit_multiplier if _is_reduction_crit() else 1.0)) 


func _get_cooldown() -> float:
	return base_cooldown - 0.025 * agility.value


func _get_damage(is_crit: bool) -> int:
	print(pow(strength.value, 2))
	return roundi(base_damage + pow(strength.value, 2) * randf_range(0.9, 1.1) * (base_crit_multiplier if is_crit else 1.0))


func _is_crit() -> bool:
	return randf_range(0.0, 1.0) <= (luck.value * 0.01 + base_crit_perc)

func _is_reduction_crit() -> bool:
	return randf_range(0.0, 1.0) <= (luck.value * 0.01 + base_crit_perc) / 2
