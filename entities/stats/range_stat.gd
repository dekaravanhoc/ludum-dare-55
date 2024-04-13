class_name RangeStat
extends Stat


signal min_value_reached
signal max_value_reached
signal value_changed


@export var min_value: float = 0.0


# adds max_value to use value as the current value of the stat clamped between max_value and min_value
var _internal_max_value: float
var max_value: float: set = _set_max_value, get = _get_max_value


func _set_max_value(_v: float) -> void: 
	pass


func _get_max_value() -> float: 
	return _internal_max_value


func _set_base(v: float) -> void:
	base_value = v
	_calculate_stat()
	_internal_value = max_value
		

func _set_value(v: float) -> void:
	_internal_value = clamp(v, min_value, max_value)
	value_changed.emit()
	if is_equal_approx(_internal_value, max_value):
		max_value_reached.emit()
	elif is_equal_approx(_internal_value, min_value):
		min_value_reached.emit()
		

func _calculate_stat() -> void:
	_internal_max_value = (
			(base_value + mods[MOD_TYPE.BaseAdd].sum) 
			* mods[MOD_TYPE.BaseMult].sum + mods[MOD_TYPE.Add].sum
			) * mods[MOD_TYPE.Mult].sum
	stat_modified.emit()
