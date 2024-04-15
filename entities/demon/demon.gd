class_name Demon
extends Node3D

@export var number_animation: NumberAnimation
@export var summon_animation: AnimationPlayer
@export var demon_animation: AnimationPlayer

@export var blood_current: Stat
@export var blood_earned: Stat
@export var experience_current: Stat
@export var reputation: RangeStat
@export var health: RangeStat
@export var defense: Stat
@export var luck: Stat
@export var strength: Stat
@export var agility: Stat
@export var number_of_battles: Stat

@export var demon_name: String
@export var growth_camera: Camera3D
@export var combat_camera: Camera3D
@export var demon_realm_camera: Camera3D
@export var health_mod: StatMod
@export var strength_mod: StatMod
@export var agility_mod: StatMod
@export var defense_mod: StatMod
@export var luck_mod: StatMod

signal demon_defeated
signal demon_won

const base_cooldown: float = 1
const best_cooldown: float = 0.1
const base_damage: int = 30
const base_crit_perc: float = .1
const base_crit_multiplier: float = 2.0

var cooldown: float = 0
var currentState: DemonState = DemonState.DEMONREALM
var enemy: Enemy

enum DemonState { FIGHT, LOSS, WIN, DEMONREALM }


func add_mods() -> void:
	health.add_mod(health_mod)
	health.value = health.max_value
	strength.add_mod(strength_mod)
	agility.add_mod(agility_mod)
	defense.add_mod(defense_mod)
	luck.add_mod(luck_mod)

func remove_mods() -> void:
	health.remove_mod(health_mod)
	strength.remove_mod(strength_mod)
	agility.remove_mod(agility_mod)
	defense.remove_mod(defense_mod)
	luck.remove_mod(luck_mod)

func build_demon(request: SummonRequest, enemy_to_attack: Enemy) -> void:
	enemy = enemy_to_attack
	cooldown = _get_cooldown()
	health.value = health.max_value
	demon_realm_camera.make_current()
	if enemy:
		enemy.enemy_defeated.connect(
			func() -> void: 
				currentState = DemonState.WIN
				await summon(true)
				experience_current.value += request.exp_gain
				number_of_battles.value += 1
				blood_current.value += request.blood_gain
				health.value = health.max_value
				demon_won.emit()
				)


func show_growth() -> void:
	growth_camera.make_current()


func start_combat() -> void:
	currentState = DemonState.FIGHT
	combat_camera.make_current()
	summon()


func reset_for_rebirth() -> void:
	reputation.value = reputation.max_value
	experience_current.value = 0
	health.remove_all_mods()
	strength.remove_all_mods()
	agility.remove_all_mods()
	defense.remove_all_mods()
	luck.remove_all_mods()


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
		_defeat()
	return dealed_damage


func summon(reverse: bool = false) -> void:
	if summon_animation:
		if reverse:
			summon_animation.play_backwards("summon_demon")
			demon_animation.play_backwards("summon")
		else:
			summon_animation.play("summon_demon")
			demon_animation.play("summon")
		await demon_animation.animation_finished
		await get_tree().create_timer(0.2).timeout
		return


func _defeat() -> void:
	currentState = DemonState.LOSS
	enemy.current_state = enemy.State.WIN
	if summon_animation:
		demon_animation.play("defeat_start")
		await demon_animation.animation_finished
		summon_animation.play_backwards("summon_demon")
		demon_animation.play("defeat_end")
		await demon_animation.animation_finished
		await get_tree().create_timer(0.2).timeout
		reputation.value -= 1
		health.value = health.max_value
		demon_defeated.emit()

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
	return clamp(roundi((damage - roundi(pow(defense.value / _get_cooldown(), 1.5))) / (base_crit_multiplier if _is_reduction_crit() else 1.0)),0,INF) 

func _get_cooldown() -> float:
	var max_agility: int = 100
	var agility_progress: float = clamp(agility.value/max_agility,0,1)
	return best_cooldown + base_cooldown - base_cooldown * ease(agility_progress,.5)

func _get_damage(is_crit: bool) -> int:
	print(pow(strength.value, 2))
	return roundi(base_damage + pow(strength.value, 2) * randf_range(0.9, 1.1) * (base_crit_multiplier if is_crit else 1.0))

func _is_crit() -> bool:
	return randf_range(0.0, 1.0) <= (luck.value * 0.01 + base_crit_perc)

func _is_reduction_crit() -> bool:
	return randf_range(0.0, 1.0) <= (luck.value * 0.01 + base_crit_perc) / 2
