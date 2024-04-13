class_name Demon
extends Node3D

@export var enemy: Enemy
@export var number_animation: NumberAnimation

@export var blood_current: Stat
@export var blood_earned: Stat
@export var reputation: Stat
@export var health: RangeStat
@export var defense: Stat
@export var luck: Stat
@export var strength: Stat
@export var agility: Stat

signal demon_defeated

var cooldown: float = 0
var currentState: DemonState

enum DemonState { FIGHT, LOSS, WIN, DEMONREALM }


func _ready() -> void:
	currentState = DemonState.DEMONREALM
	cooldown = Combat.getCooldown(agility.value)
	health.value = health.max_value
	enemy.enemy_defeated.connect(func() -> void: currentState = DemonState.WIN)


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
	var dealed_damage: int = Combat.getHitDamage(_damage, defense.value)
	health.value -= dealed_damage
	if health.value <= 0:
		currentState = DemonState.LOSS
		demon_defeated.emit()
	return dealed_damage


func _fight(_delta: float) -> void:
	cooldown -= _delta
	if cooldown < 0:
		_attack()
		cooldown = Combat.getCooldown(agility.value)


func _attack() -> void:
	var enemy_screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(
		enemy.position
	)
	var isCrit: bool = Combat.getCrit(luck.value)
	var damage: int = Combat.getDamage(strength.value, isCrit)
	var damage_text: String = "Crit" if isCrit else ""
	# add skill damage and set skill name/color
	var dealed_damage: int = enemy.hit(damage)
	number_animation.add_damage(enemy_screen_pos, dealed_damage, Color.DARK_RED, damage_text)

