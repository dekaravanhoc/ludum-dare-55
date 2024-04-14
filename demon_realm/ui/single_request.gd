class_name SingleRequest
extends MarginContainer

@export var battle_name: Label
@export var blood_amount: Label
@export var button: Button
@export var summon_icon: TextureRect

var request: SummonRequest = SummonRequest.new()


func add_to_button_group(button_group: ButtonGroup) -> void:
	button.button_group = button_group

func _ready() -> void:
	battle_name.text = request.request_name
	blood_amount.text = "%4d" % request.blood_gain
	
	print("SummonRequest Difficulty: %d" % request.difficulty)
	match(request.difficulty):
		var difficulty when difficulty < - 1:
			summon_icon.self_modulate = Color.PALE_VIOLET_RED
		var difficulty when difficulty > 1:
			summon_icon.self_modulate = Color.DARK_VIOLET
		_:
			summon_icon.self_modulate = Color.RED
