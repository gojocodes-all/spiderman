class_name PlayerInputRouter
extends Node

var _touch_move := Vector2.ZERO
var _touch_jump_requested := false
var _touch_sprint_held := false
var _touch_burst_requested := false
var _snapshot := PlayerInputSnapshot.new()


func _ready() -> void:
	_register_action(&"move_forward", [KEY_W, KEY_UP], JOY_AXIS_LEFT_Y, -1.0)
	_register_action(&"move_back", [KEY_S, KEY_DOWN], JOY_AXIS_LEFT_Y, 1.0)
	_register_action(&"move_left", [KEY_A, KEY_LEFT], JOY_AXIS_LEFT_X, -1.0)
	_register_action(&"move_right", [KEY_D, KEY_RIGHT], JOY_AXIS_LEFT_X, 1.0)
	_register_action(&"look_up", [], JOY_AXIS_RIGHT_Y, -1.0)
	_register_action(&"look_down", [], JOY_AXIS_RIGHT_Y, 1.0)
	_register_action(&"look_left", [], JOY_AXIS_RIGHT_X, -1.0)
	_register_action(&"look_right", [], JOY_AXIS_RIGHT_X, 1.0)
	_register_action(&"jump", [KEY_SPACE], -1, 0.0, JOY_BUTTON_A)
	_register_action(&"walk", [KEY_CTRL], -1, 0.0, JOY_BUTTON_LEFT_SHOULDER)
	_register_action(&"sprint", [KEY_SHIFT], -1, 0.0, JOY_BUTTON_LEFT_STICK)
	_register_action(&"burst", [KEY_E], -1, 0.0, JOY_BUTTON_RIGHT_SHOULDER)
	_register_action(&"camera_recenter", [KEY_C], -1, 0.0, JOY_BUTTON_RIGHT_STICK)
	_register_action(&"traversal_debug", [KEY_F8])


func set_touch_move(value: Vector2) -> void:
	_touch_move = value.limit_length(1.0)


func request_touch_jump() -> void:
	_touch_jump_requested = true


func set_touch_sprint(held: bool) -> void:
	_touch_sprint_held = held


func request_touch_burst() -> void:
	_touch_burst_requested = true


func consume_snapshot() -> PlayerInputSnapshot:
	var keyboard_move := Input.get_vector(
		&"move_left",
		&"move_right",
		&"move_forward",
		&"move_back"
	)
	var selected_move := _touch_move if _touch_move.length_squared() > 0.0025 else keyboard_move
	_snapshot.move = selected_move.limit_length(1.0)
	_snapshot.jump_pressed = Input.is_action_just_pressed(&"jump") or _touch_jump_requested
	_snapshot.sprint_held = Input.is_action_pressed(&"sprint") or _touch_sprint_held
	_snapshot.walk_held = Input.is_action_pressed(&"walk")
	_snapshot.burst_pressed = Input.is_action_just_pressed(&"burst") or _touch_burst_requested
	_touch_jump_requested = false
	_touch_burst_requested = false
	return _snapshot


func clear_touch_input() -> void:
	_touch_move = Vector2.ZERO
	_touch_jump_requested = false
	_touch_sprint_held = false
	_touch_burst_requested = false


func _register_action(
	action: StringName,
	keycodes: Array[int],
	joy_axis: JoyAxis = -1,
	joy_axis_value: float = 0.0,
	joy_button: JoyButton = -1
) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.18)
	if not InputMap.action_get_events(action).is_empty():
		return
	for keycode in keycodes:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)
	if joy_axis >= 0:
		var axis_event := InputEventJoypadMotion.new()
		axis_event.axis = joy_axis
		axis_event.axis_value = joy_axis_value
		InputMap.action_add_event(action, axis_event)
	if joy_button >= 0:
		var button_event := InputEventJoypadButton.new()
		button_event.button_index = joy_button
		InputMap.action_add_event(action, button_event)
