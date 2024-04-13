class_name NumberAnimation
extends Node2D


class Number:
	extends RefCounted
	var position: Vector2
	var text: String
	var font_size: int
	var color: Color


@export font: FontFile

var current_numbers: Array[Number]


func _ready() -> void:
	pass


func add_damage(spawn_position: Vector2, damage: float, color: Color = Color.RED, prefix_text: String = "") -> void:
	var damage_weight: float = ease(minf(damage / 100.0, 1.0), 3)
	_add_number(
		spawn_position,
		prefix_text + str(round(damage)),
		int(lerpf(32.0, 96.0, damage_weight)),
		Color.YELLOW,
		lerpf(1.0, 2.0, damage_weight)
	)


func _add_number(
	spawn_position: Vector2,
	text: String,
	font_size: int,
	color: Color,
	time: float = 0.5,
	offset: Vector2 = Vector2(10, -30)
) -> void:
	var number: Number = Number.new()
	# Incorporate camera-zoom etc.
	number.position = get_viewport().get_canvas_transform() * spawn_position + offset
	number.text = text
	number.font_size = font_size
	number.color = color
	number.color.a = 0

	current_numbers.append(number)

	var tween: Tween = create_tween()

	tween.tween_property(number, "color:a", 1.0, 0.1)
	tween.parallel()
	tween.tween_property(number, "position", number.position + Vector2(30, -100), time)
	tween.parallel()
	tween.tween_property(number, "color:a", 0.0, 0.25).set_delay(time - 0.25).from(1.0)
	tween.tween_callback(func() -> void: current_numbers.erase(number))


func _process(_delta: float) -> void:
	if current_numbers.is_empty():
		return
	queue_redraw()


func _draw() -> void:
	for number: Number in current_numbers:
		draw_string(
			font,
			number.position,
			number.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			number.font_size,
			number.color
		)

