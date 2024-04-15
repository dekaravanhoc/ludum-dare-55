extends Node3D

@export var start_demon: PackedScene

@export var start_button: Button
@export var grow_button: Button
@export var credits_button: Button
@export var exit_button: Button
@export var scene_switch: TextureRect

@export var menu: Control
@export var credits: PanelContainer
@export var grow: GrowthUI

var number_of_battles: Stat = preload("res://entities/demon/stats/demon_number_of_battle.tres")

var combat_scene: PackedScene = preload("res://combat/combat.tscn")
var demon_realm_scene: PackedScene = preload("res://demon_realm/demon_realm.tscn")

var current_combat: Combat
var current_demon_realm: DemonRealm

@onready var current_demon: PackedScene = start_demon

func _ready() -> void:
	start_button.pressed.connect(_start_game)
	grow_button.pressed.connect(_show_grow)
	credits_button.pressed.connect(_show_credits)
	exit_button.pressed.connect(_exit)
	grow.growth_selected.connect(_grow)

	current_demon_realm = demon_realm_scene.instantiate()
	add_child(current_demon_realm)
	var demon: Demon = current_demon.instantiate()
	await current_demon_realm.add_demon(demon)
	demon.add_mods()
	current_demon_realm.ui.hide()


func _start_game() -> void:
	var first_battle_request: SummonRequest = SummonRequest.new(true)
	grow.hide()
	credits.hide()
	menu.hide()
	_init_combat(first_battle_request)


func _init_combat(request: SummonRequest) -> void:
	await current_demon_realm.demon.summon(true)
	_scene_switch_animation(func() -> void: 
		current_combat = combat_scene.instantiate()
		current_demon_realm.hide()
		current_demon_realm.queue_free()
		add_child(current_combat)
		var demon: Demon = current_demon.instantiate()
		current_combat.start_combat(request, demon)
		current_combat.combat_finished.connect(_init_demon_realm)
		)


func _init_demon_realm() -> void:
	_scene_switch_animation(func() -> void: 
		current_combat.hide()
		current_combat.queue_free()
		current_demon_realm = demon_realm_scene.instantiate()
		var demon: Demon = current_demon.instantiate()
		add_child(current_demon_realm)
		current_demon_realm.add_demon(demon)
		current_demon_realm.combat_requested.connect(_init_combat)
		current_demon_realm.rebirth_requested.connect(_rebirth)
		)


func _scene_switch_animation(scene_switch_func: Callable) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(scene_switch, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_interval(0.25)
	tween.tween_callback(scene_switch_func)
	tween.tween_property(scene_switch, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)



func _rebirth() -> void:
	_scene_switch_animation(func() -> void:
		current_demon_realm.hide()
		current_demon_realm.queue_free()
		await get_tree().process_frame
		current_demon_realm = demon_realm_scene.instantiate()
		var demon: Demon = current_demon.instantiate()
		add_child(current_demon_realm)
		current_demon_realm.combat_requested.connect(_init_combat)
		current_demon_realm.rebirth_requested.connect(_rebirth)
		number_of_battles.value = 1
		current_demon_realm.add_demon(demon, false)
		demon.reset_for_rebirth()
		demon.add_mods()
		current_demon_realm.ui.hide()
		menu.show()
		)


func _show_credits() -> void:
	grow.hide()
	credits.visible = not credits.is_visible_in_tree()


func _show_grow() -> void:
	credits.hide()
	grow.visible = not grow.is_visible_in_tree()


func _grow(demon_scene: PackedScene) -> void:
	current_demon = demon_scene
	await current_demon_realm.demon.summon(true)
	current_demon_realm.demon.queue_free()
	await get_tree().process_frame
	var demon: Demon = current_demon.instantiate()
	demon.add_mods()
	await current_demon_realm.add_demon(demon, true)
	current_demon_realm.ui.hide()



func _exit() -> void:
	get_tree().quit()

