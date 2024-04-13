class_name NumberAnimation
extends Node2D


class Number:
	extends RefCounted
	var position: Vector2
	var text: String
	var font_size: int
	var color: Color


@export var font: FontFile

var current_numbers: Array[Number]


func _ready() -> void:
	pass


func add_damage(spawn_position: Vector2, damage: float, color: Color = Color.RED, prefix_text: String = "") -> void:
	var damage_weight: float = ease(minf(damage / 50000.0, 1.0), 1.3)
	_add_number(
		spawn_position,
		prefix_text + str(round(damage)),
		int(lerpf(128.0, 128 * 5, damage_weight)),
		color,
		lerpf(1.0, 3.0, damage_weight),
		lerpf(3.0, 1.0, damage_weight)
	)


func _add_number(
	spawn_position: Vector2,
	text: String,
	font_size: int,
	color: Color,
	time: float = 0.5,
	move_range:float = 1,
	offset: Vector2 = Vector2(10, -30)
) -> void:
	var number: Number = Number.new()
	# Incorporate camera-zoom etc.
	number.position = get_viewport().get_canvas_transform() * spawn_position + offset
	number.text = text
	number.font_size = font_size
	number.color = color
	number.color.a = 0
	number.position.x += -(number.font_size)  + randi_range(-100, 100)

	current_numbers.append(number)

	var tween: Tween = create_tween()

	tween.tween_property(number, "color:a", 1.0, 0.1)
	tween.parallel()
	tween.tween_property(number, "position", number.position + Vector2(30, -100) * move_range, time)
	tween.parallel()
	tween.tween_property(number, "font_size", number.font_size * 1.2, time/2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.parallel()
	tween.tween_property(number, "color:a", 0.0, time/2).set_delay(time/2).from(1.0)
	tween.tween_callback(func() -> void: current_numbers.erase(number))


func _process(_delta: float) -> void:
	if current_numbers.is_empty():
		return
	queue_redraw()


func _draw() -> void:
	for number: Number in current_numbers:
		draw_string_outline(
			font,
			number.position,
			number.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			roundi(number.font_size),
			ceili(number.font_size * 0.1),
			Color(number.color.r * 0.2, number.color.g * 0.2, number.color.b * 0.2, number.color.a)
		)
		draw_string(
			font,
			number.position,
			number.text,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			number.font_size,
			number.color
		)

