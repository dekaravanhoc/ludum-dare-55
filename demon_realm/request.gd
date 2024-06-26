class_name SummonRequest
extends RefCounted

var blood_gain: int = 1
var enemy_types: Array[Enemy.EnemyType]
var request_name: String
var exp_multiplier: float
var difficulty: int
var exp_gain: int = 100

func _init(first: bool = false) -> void:
	var number_of_battle: Stat = load("res://entities/demon/stats/demon_number_of_battle.tres")
	difficulty = randi_range(- 3, 2) if not first else 0
	exp_gain = roundi(pow(exp_gain * maxi(1, int(number_of_battle.value) + difficulty), 1.07))
	blood_gain = roundi(pow(blood_gain * maxi(1, int(number_of_battle.value) + difficulty), 2.5))
	exp_multiplier = pow(maxi(1, int(number_of_battle.value) + difficulty), 2.7)
	for n: int in min(exp_multiplier, Enemy.EnemyTypes.NUMBER_OF_ENEMY_TYPES * 2):
		enemy_types.append(Enemy.EnemyTypes.get_random_enemy_type())
	print("Blood Gain: %d, Exp Gain: %d, Multiplyer: %d, Difficulty: %d" % [blood_gain, exp_gain, exp_multiplier, difficulty])
