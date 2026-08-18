class_name TouchInputOverlay
extends Control

var _input_router: PlayerInputRouter
var _camera_rig: ThirdPersonCameraRig
var _move_touch_id := -1
var _look_touch_id := -1
var _move_origin := Vector2.ZERO
var _move_value := Vector2.ZERO
var _last_look_position := Vector2.ZERO
var _joystick_radius := 76.0

var _jump_button: Button
var _burst_button: Button


func _ready() -> void:
	set_process_input(true)
	resized.connect(_on_resized)
	_create_hud()
	_create_action_buttons()
	_reset_move_origin()
	queue_redraw()


func bind(input_router: PlayerInputRouter, camera_rig: ThirdPersonCameraRig) -> void:
	_input_router = input_router
	_camera_rig = camera_rig


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event)


func _draw() -> void:
	var base_color := Color(0.2, 0.82, 0.82, 0.16)
	var line_color := Color(0.4, 0.95, 0.92, 0.62)
	draw_circle(_move_origin, _joystick_radius, base_color)
	draw_arc(_move_origin, _joystick_radius, 0.0, TAU, 40, line_color, 2.0, true)
	draw_circle(_move_origin + _move_value * _joystick_radius * 0.64, 28.0, Color(0.4, 0.95, 0.92, 0.46))


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if event.position.x < size.x * 0.5 and _move_touch_id == -1:
			_move_touch_id = event.index
			_move_origin = event.position
			_update_move(event.position)
			get_viewport().set_input_as_handled()
		elif not _point_over_action_buttons(event.position) and _look_touch_id == -1:
			_look_touch_id = event.index
			_last_look_position = event.position
	else:
		if event.index == _move_touch_id:
			_move_touch_id = -1
			_move_value = Vector2.ZERO
			if _input_router:
				_input_router.set_touch_move(Vector2.ZERO)
			_reset_move_origin()
			queue_redraw()
		elif event.index == _look_touch_id:
			_look_touch_id = -1


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	if event.index == _move_touch_id:
		_update_move(event.position)
		get_viewport().set_input_as_handled()
	elif event.index == _look_touch_id:
		var delta := event.position - _last_look_position
		_last_look_position = event.position
		if _camera_rig:
			_camera_rig.apply_look_delta(delta)
		get_viewport().set_input_as_handled()


func _update_move(position_value: Vector2) -> void:
	_move_value = ((position_value - _move_origin) / _joystick_radius).limit_length(1.0)
	if _input_router:
		_input_router.set_touch_move(_move_value)
	queue_redraw()


func _create_hud() -> void:
	var title := Label.new()
	title.text = "AERIAL VANGUARD // RELAY"
	title.position = Vector2(28.0, 22.0)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("74e2dc"))
	add_child(title)

	var status := Label.new()
	status.text = "M0 ANDROID PACKAGE SMOKE  •  PROCEDURAL BLOCKOUT  •  NO EXTERNAL ART"
	status.position = Vector2(30.0, 52.0)
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", Color(0.75, 0.8, 0.86, 0.88))
	add_child(status)

	var help := Label.new()
	help.text = "MOVE  left thumb / WASD     LOOK  right drag / RMB     JUMP  Space     BURST  Shift"
	help.anchor_top = 1.0
	help.anchor_bottom = 1.0
	help.offset_left = 28.0
	help.offset_top = -38.0
	help.offset_right = 800.0
	help.offset_bottom = -14.0
	help.add_theme_font_size_override("font_size", 13)
	help.add_theme_color_override("font_color", Color(0.78, 0.82, 0.88, 0.8))
	add_child(help)


func _create_action_buttons() -> void:
	_jump_button = _make_action_button("JUMP", Vector2(-142.0, -126.0), Vector2(-28.0, -70.0))
	_burst_button = _make_action_button("BURST", Vector2(-260.0, -88.0), Vector2(-154.0, -36.0))
	_jump_button.button_down.connect(_request_jump)
	_burst_button.button_down.connect(_request_burst)


func _make_action_button(label_text: String, offset_a: Vector2, offset_b: Vector2) -> Button:
	var button := Button.new()
	button.text = label_text
	button.focus_mode = Control.FOCUS_NONE
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset_a.x
	button.offset_top = offset_a.y
	button.offset_right = offset_b.x
	button.offset_bottom = offset_b.y
	button.modulate = Color(0.55, 0.95, 0.9, 0.82)
	add_child(button)
	return button


func _request_jump() -> void:
	if _input_router:
		_input_router.request_touch_jump()


func _request_burst() -> void:
	if _input_router:
		_input_router.request_touch_burst()


func _point_over_action_buttons(point: Vector2) -> bool:
	for button in [_jump_button, _burst_button]:
		if button and Rect2(button.global_position, button.size).has_point(point):
			return true
	return false


func _on_resized() -> void:
	if _move_touch_id == -1:
		_reset_move_origin()
	queue_redraw()


func _reset_move_origin() -> void:
	_move_origin = Vector2(size.x * 0.15, size.y * 0.76)
