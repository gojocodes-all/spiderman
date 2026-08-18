class_name PlayerInputRouter
extends Node

var _touch_move := Vector2.ZERO
var _touch_jump_requested := false
var _touch_burst_requested := false


func _ready() -> void:
	_register_keyboard_action(&"move_forward", [KEY_W, KEY_UP])
	_register_keyboard_action(&"move_back", [KEY_S, KEY_DOWN])
	_register_keyboard_action(&"move_left", [KEY_A, KEY_LEFT])
	_register_keyboard_action(&"move_right", [KEY_D, KEY_RIGHT])
	_register_keyboard_action(&"jump", [KEY_SPACE])
	_register_keyboard_action(&"burst", [KEY_SHIFT])


func set_touch_move(value: Vector2) -> void:
	_touch_move = value.limit_length(1.0)


func request_touch_jump() -> void:
	_touch_jump_requested = true


func request_touch_burst() -> void:
	_touch_burst_requested = true


func consume_snapshot() -> Dictionary:
	var keyboard_move := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_back"
	)
	var selected_move := _touch_move if _touch_move.length_squared() > 0.0025 else keyboard_move
	var snapshot := {
		"move": selected_move.limit_length(1.0),
		"jump": Input.is_action_just_pressed(&"jump") or _touch_jump_requested,
		"burst": Input.is_action_just_pressed(&"burst") or _touch_burst_requested,
	}
	_touch_jump_requested = false
	_touch_burst_requested = false
	return snapshot


func _register_keyboard_action(action: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.18)
	if not InputMap.action_get_events(action).is_empty():
		return
	for keycode in keycodes:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)
