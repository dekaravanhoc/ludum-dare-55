class_name Stat
extends Resource


# Signals when the stat is modified
signal stat_modified


# Max sum vor mult mods
const MULT_MAX: int = 100


# Base Mods are calculated first 
# Calculation: ((basevalue + sum of BaseAdd) * sum of BaseMult + sum of Add) * sum of BaseMult
# Mult sums are always added with 1.0
enum MOD_TYPE {BaseAdd, BaseMult, Add, Mult}


# Name of the stat to be used in UI etc. 
@export var stat_name: String = "Stat"
# Start value of the stat - Base to be modified upon
@export var base_value: float = 1.0: set = _set_base


var mods: Dictionary = {
	MOD_TYPE.BaseAdd : {
		list = [], 
		sum = 0.0
	},
	MOD_TYPE.BaseMult : {
		list = [], 
		sum = 1.0
	},
	MOD_TYPE.Add : {
		list = [], 
		sum = 0.0
	},
	MOD_TYPE.Mult : {
		list = [], 
		sum = 1.0
	}
}

var _internal_value: float
var value: float: set = _set_value, get = _get_value


func _set_base(v: float) -> void:
		base_value = v
		_calculate_stat()
		

func _get_value() -> float: 
	return _internal_value
	

func _set_value(v: float) -> void:
	base_value = v


# func _init() -> void:
# 	# Stats are unique to each scene
# 	resource_local_to_scene = true
	
	
func add_mod(mod: StatMod) -> bool:
	var mod_type_list: Array = mods[mod.type].list
	if mod_type_list.has(mod):
		push_warning(mod.to_string() + " already added to list")
		return false
	mod_type_list.append(mod)
	_recalculate(mod.type)
	_calculate_stat()
	mod.stat_mod_modified.connect(_stat_mod_modified)
	mod.stat_mod_removed.connect(remove_mod, CONNECT_ONE_SHOT)
	return true
	

func remove_mod(mod: StatMod) -> bool:
	var mod_type_list: Array = mods[mod.type].list
	if !mod_type_list.has(mod):
		push_warning(mod.to_string() + " not in list")
		return false
	mod_type_list.erase(mod)
	_recalculate(mod.type)
	_calculate_stat()
	mod.stat_mod_modified.disconnect(_stat_mod_modified)
	return true


func remove_all_mods() -> void:
	mods = {
	MOD_TYPE.BaseAdd : {
		list = [], 
		sum = 0.0
	},
	MOD_TYPE.BaseMult : {
		list = [], 
		sum = 1.0
	},
	MOD_TYPE.Add : {
		list = [], 
		sum = 0.0
	},
	MOD_TYPE.Mult : {
		list = [], 
		sum = 1.0
	}
}



func modify_value_by_base_mult(value_to_modify: float) -> float:
	return value_to_modify * mods[MOD_TYPE.BaseMult]


func _stat_mod_modified(mod: StatMod) -> void:
	_recalculate(mod.type)
	

func _recalculate(type: MOD_TYPE) -> void:
	var new_sum: float = 0.0
	for mod: StatMod in mods[type].list:
		new_sum += mod.value
	mods[type].sum = new_sum
	if type == MOD_TYPE.BaseMult or type == MOD_TYPE.Mult:
		mods[type].sum += 1.0
		mods[type].sum = clamp(mods[type].sum, 0, MULT_MAX)
	_calculate_stat()


func _calculate_stat() -> void:
	_internal_value = (
			(base_value + mods[MOD_TYPE.BaseAdd].sum) 
			* mods[MOD_TYPE.BaseMult].sum + mods[MOD_TYPE.Add].sum
			) * mods[MOD_TYPE.Mult].sum
	stat_modified.emit()
