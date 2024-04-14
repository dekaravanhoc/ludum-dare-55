class_name RequestUI
extends Control

signal contract_signed(request: SummonRequest)

@export var sign_contract_button: Button
@export var request_container: GridContainer
@export var reputation_amount: Label

var single_request_scene: PackedScene = preload("res://demon_realm/ui/single_request.tscn")
var reputation: RangeStat = preload("res://entities/demon/stats/demon_reputation.tres")
var single_request_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	reputation_amount.text = "%d" % reputation.value
	single_request_button_group.allow_unpress = true
	sign_contract_button.disabled = true
	single_request_button_group.pressed.connect(
		func(_button: BaseButton) -> void:
			sign_contract_button.disabled = not single_request_button_group.get_pressed_button() is Button
			)
	for n: int in int(reputation.value):
		var new_request: SingleRequest = single_request_scene.instantiate()
		new_request.add_to_button_group(single_request_button_group)
		request_container.add_child(new_request)
	
	sign_contract_button.pressed.connect(_sign_contract)


func _sign_contract() -> void:
	var request: SingleRequest = single_request_button_group.get_pressed_button().get_parent()
	contract_signed.emit(request.request)
