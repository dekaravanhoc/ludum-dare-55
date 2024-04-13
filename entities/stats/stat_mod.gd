class_name StatMod
extends Resource

signal stat_mod_modified(mod: StatMod)
signal stat_mod_removed(mod: StatMod)

# Type of the Mod based on Stat.MOD_TYPE
@export var type: Stat.MOD_TYPE = Stat.MOD_TYPE.Add
@export var value: float = 0.0:
	set(v):
		value = v
		stat_mod_modified.emit(self)
# Can be used to show modifier name in UI etc.
@export var mod_name: String = "Stat Modifier Y"

# func _init() -> void:
# 	# StatMods should be unique to all scenes
# 	resource_local_to_scene = true


func remove() -> void:
	stat_mod_removed.emit(self)

