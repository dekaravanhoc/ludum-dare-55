extends Node3D

@export var start_button: Button
@export var grow_button: Button
@export var credits_button: Button
@export var exit_button: Button

@export var menu: Control
@export var credits: PanelContainer
@export var grow: PanelContainer

var number_of_battles: Stat = preload("res://entities/demon/stats/demon_number_of_battle.tres")

var combat_scene: PackedScene = preload("res://combat/combat.tscn")
var demon_realm_scene: PackedScene = preload("res://demon_realm/demon_realm.tscn")

var current_combat: Combat
var current_demon_realm: DemonRealm


func _ready() -> void:
	start_button.pressed.connect(_start_game)
	grow_button.pressed.connect(_show_grow)
	credits_button.pressed.connect(_show_credits)
	exit_button.pressed.connect(_exit)

	current_demon_realm = demon_realm_scene.instantiate()
	add_child(current_demon_realm)
	current_demon_realm.ui.hide()


func _start_game() -> void:
	var first_battle_request: SummonRequest = SummonRequest.new()
	grow.hide()
	credits.hide()
	menu.hide()
	_init_combat(first_battle_request)


func _init_combat(request: SummonRequest) -> void:
	current_combat = combat_scene.instantiate()
	current_demon_realm.queue_free()
	add_child(current_combat)
	current_combat.start_combat(request)
	current_combat.combat_finished.connect(_init_demon_realm)
	number_of_battles.value += 1


func _init_demon_realm() -> void:
	current_combat.queue_free()
	current_demon_realm = demon_realm_scene.instantiate()
	add_child(current_demon_realm)
	current_demon_realm.ui.combat_requested.connect(_init_combat)


func _show_credits() -> void:
	grow.hide()
	credits.visible = not credits.is_visible_in_tree()


func _show_grow() -> void:
	credits.hide()
	grow.visible = not grow.is_visible_in_tree()


func _exit() -> void:
	get_tree().quit()
