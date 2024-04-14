class_name SummonRequest
extends RefCounted

var blood_gain: int
var enemy_types: Array[Enemy.EnemyType]
var request_name: String
var exp_multiplier: float
var difficulty: int
var exp_gain: int = 100

func _init() -> void:
	var reputation: RangeStat = load("res://entities/demon/stats/demon_reputation.tres")
	var number_of_battle: Stat = load("res://entities/demon/stats/demon_number_of_battle.tres")
	var reputation_diff: int = int(reputation.max_value - reputation.value)
	difficulty = randi_range(-reputation_diff - 3, -reputation_diff + 3)
	exp_gain = roundi(exp_gain * pow(1.07, maxi(1, int(number_of_battle.value) + difficulty)))
	blood_gain = roundi(pow(exp_gain / 100.0, 0.6))
	exp_multiplier = maxi(1, roundi(pow(exp_gain / 100.0, 2.0)))
	for n: int in min(exp_multiplier, Enemy.EnemyTypes.NUMBER_OF_ENEMY_TYPES * 2):
		enemy_types.append(Enemy.EnemyTypes.get_random_enemy_type())
	print("Blood Gain: %d, Exp Gain: %d, Multiplyer: %d, Difficulty: %d" % [blood_gain, exp_gain, exp_multiplier, difficulty])
