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
var _sprint_button: Button
var _burst_button: Button
var _safe_rect := Rect2()


func _ready() -> void:
	set_process_input(true)
	resized.connect(_on_resized)
	_create_hud()
	_create_action_buttons()
	_apply_safe_area_layout()
	queue_redraw()


func _exit_tree() -> void:
	_release_touch_input()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		_release_touch_input()


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
	status.text = "M2 PARKOUR LAB  •  CONTEXTUAL WALL / VAULT / MANTLE / LEDGE TRAVERSAL  •  ORIGINAL GRAYBOX"
	status.position = Vector2(30.0, 52.0)
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", Color(0.75, 0.8, 0.86, 0.88))
	add_child(status)

	var help := Label.new()
	help.text = "MOVE / LOOK / JUMP drive contextual parkour   SPRINT builds momentum   F8 traversal debug   BURST remains a test probe"
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
	_burst_button = _make_action_button("BURST", Vector2(-268.0, -90.0), Vector2(-158.0, -38.0))
	_sprint_button = _make_action_button("SPRINT", Vector2(-390.0, -90.0), Vector2(-280.0, -38.0))
	_jump_button.button_down.connect(_request_jump)
	_burst_button.button_down.connect(_request_burst)
	_sprint_button.button_down.connect(_set_sprint.bind(true))
	_sprint_button.button_up.connect(_set_sprint.bind(false))


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


func _set_sprint(held: bool) -> void:
	if _input_router:
		_input_router.set_touch_sprint(held)


func _point_over_action_buttons(point: Vector2) -> bool:
	for button in [_jump_button, _sprint_button, _burst_button]:
		if button and Rect2(button.global_position, button.size).has_point(point):
			return true
	return false


func _on_resized() -> void:
	_joystick_radius = clampf(minf(size.x, size.y) * 0.105, 62.0, 92.0)
	_apply_safe_area_layout()
	queue_redraw()


func _reset_move_origin() -> void:
	var safe_rect := _safe_rect if _safe_rect.size.x > 0.0 and _safe_rect.size.y > 0.0 else Rect2(Vector2.ZERO, size)
	_move_origin = safe_rect.position + safe_rect.size * Vector2(0.15, 0.76)


func _apply_safe_area_layout() -> void:
	_safe_rect = _display_safe_rect(size)
	var safe_end_offset := _safe_rect.end - size
	_set_action_button_offsets(_jump_button, Vector2(-142.0, -126.0) + safe_end_offset, Vector2(-28.0, -70.0) + safe_end_offset)
	_set_action_button_offsets(_burst_button, Vector2(-268.0, -90.0) + safe_end_offset, Vector2(-158.0, -38.0) + safe_end_offset)
	_set_action_button_offsets(_sprint_button, Vector2(-390.0, -90.0) + safe_end_offset, Vector2(-280.0, -38.0) + safe_end_offset)
	if _move_touch_id == -1:
		_reset_move_origin()


func _set_action_button_offsets(button: Button, offset_a: Vector2, offset_b: Vector2) -> void:
	if not button:
		return
	button.offset_left = offset_a.x
	button.offset_top = offset_a.y
	button.offset_right = offset_b.x
	button.offset_bottom = offset_b.y


func _display_safe_rect(viewport_size: Vector2) -> Rect2:
	if OS.get_name() not in ["Android", "iOS"]:
		return Rect2(Vector2.ZERO, viewport_size)
	var display_size := Vector2(DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW))
	if display_size.x <= 0.0 or display_size.y <= 0.0:
		return Rect2(Vector2.ZERO, viewport_size)
	var display_safe_area := DisplayServer.get_display_safe_area()
	if display_safe_area.size.x <= 0 or display_safe_area.size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	var scale := viewport_size / display_size
	var safe_position := Vector2(display_safe_area.position) * scale
	var safe_size := Vector2(display_safe_area.size) * scale
	var safe_end := (safe_position + safe_size).min(viewport_size)
	safe_position = safe_position.max(Vector2.ZERO)
	return Rect2(safe_position, (safe_end - safe_position).max(Vector2.ZERO))


func _release_touch_input() -> void:
	_move_touch_id = -1
	_look_touch_id = -1
	_move_value = Vector2.ZERO
	if _input_router:
		_input_router.clear_touch_input()
	if is_node_ready():
		_reset_move_origin()
		queue_redraw()


func debug_layout_snapshot(viewport_size: Vector2, safe_rect := Rect2()) -> Dictionary:
	if safe_rect.size.x <= 0.0 or safe_rect.size.y <= 0.0:
		safe_rect = Rect2(Vector2.ZERO, viewport_size)
	var safe_end := safe_rect.end
	return {
		"safe_rect": safe_rect,
		"move_center": safe_rect.position + safe_rect.size * Vector2(0.15, 0.76),
		"move_radius": clampf(minf(viewport_size.x, viewport_size.y) * 0.105, 62.0, 92.0),
		"jump": Rect2(safe_end + Vector2(-142.0, -126.0), Vector2(114.0, 56.0)),
		"burst": Rect2(safe_end + Vector2(-268.0, -90.0), Vector2(110.0, 52.0)),
		"sprint": Rect2(safe_end + Vector2(-390.0, -90.0), Vector2(110.0, 52.0)),
	}


func debug_touch_ids() -> Vector2i:
	return Vector2i(_move_touch_id, _look_touch_id)
