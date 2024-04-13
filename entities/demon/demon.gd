class_name Demon
extends Node3D

@export var enemy: Enemy
@export var number_animation: NumberAnimation
@export var base_cooldown: float = 1
@export var base_crit_perc: float = .1
@export var base_crit_multiplier: float = 1.5

@export var blood_current: Stat
@export var blood_earned: Stat
@export var reputation: Stat

@export var max_health: Stat
@export var defense: Stat
@export var luck: Stat
@export var strength: Stat
@export var agility: Stat

var cooldown:float = 0
var currentState: DemonState
var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var health:float = 0

enum DemonState {
	FIGHT,
	LOSS,
	WIN,
	DEMONREALM
}

func _ready()-> void:
	currentState = DemonState.FIGHT
	cooldown = _getCooldown()
	health = max_health._get_value()
	
func _process(_delta: float)-> void:
	match currentState:
		DemonState.FIGHT: 
			_fight(_delta)
		DemonState.LOSS:
			print("Demon loss!")
		DemonState.WIN:
			print("Demon win!")
		DemonState.DEMONREALM:
			print("Demon chillin")

func hit(_damage: float)->void:
	health = clamp(_damage,0, max_health._get_value())
	if(health == 0):
		currentState = DemonState.LOSS

func _fight(_delta: float)->void:
	cooldown -= _delta
	if(cooldown < 0):
		_attack()
		cooldown = _getCooldown();

func _attack()-> void:
	var enemy_screen_pos: Vector2 = get_viewport().get_camera_3d().unproject_position(enemy.position)
	var isCrit: bool = _getCrit()
	var damage: float = _getDamage()
	var damage_text: String = "Crit" if isCrit else ""
	# add skill damage and set skill name/color
	damage *= base_crit_multiplier if isCrit else 1
	number_animation.add_damage(enemy_screen_pos, damage, Color.DARK_RED, "")
	enemy.hit(damage)

func _getHitDamage(_damage: float)->float:
	return _damage / defense._get_value()

func _getCooldown()->float:
	return base_cooldown / agility._get_value()

func _getDamage()->float:
	var base_attack: float = 100 * strength._get_value()
	return base_attack * rng.randf_range(0.9, 1.1)
	
func _getCrit()->bool:
	return rng.randf_range(0, 1 + luck._get_value()) > (1-base_crit_perc)

