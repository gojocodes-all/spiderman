class_name ThirdPersonCameraRig
extends Node3D

@export var tuning: ThirdPersonCameraTuning = preload("res://game/data/movement/default_camera_tuning.tres")

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _target: CharacterBody3D
var _yaw := 0.0
var _pitch := 0.0
var _mouse_looking := false
var _manual_look_idle := 0.0
var _requested_recenter := false
var _horizontal_velocity := Vector3.ZERO
var _wish_direction := Vector3.ZERO
var _move_strength := 0.0
var _smoothed_look_ahead := Vector3.ZERO
var _traversal_state := &"idle"
var _traversal_direction := Vector3.ZERO
var _traversal_wall_normal := Vector3.ZERO
var _traversal_blend := 0.0


func _ready() -> void:
	_target = get_parent() as CharacterBody3D
	var preserved_transform := global_transform
	top_level = true
	global_transform = preserved_transform
	_yaw = global_rotation.y
	_pitch = deg_to_rad(tuning.default_pitch_degrees)
	if _target:
		global_position = _target.global_position + tuning.target_offset
		spring_arm.add_excluded_object(_target.get_rid())
	var collision_shape := SphereShape3D.new()
	collision_shape.radius = tuning.collision_probe_radius
	spring_arm.shape = collision_shape
	spring_arm.margin = tuning.collision_margin
	spring_arm.spring_length = tuning.base_arm_length
	camera.fov = tuning.base_field_of_view
	_apply_rotation()


func _process(delta: float) -> void:
	_read_controller_look(delta)
	if Input.is_action_just_pressed(&"camera_recenter"):
		request_recenter()
	_manual_look_idle += delta
	_update_recenter(delta)
	_update_follow(delta)
	_update_speed_response(delta)
	_apply_rotation()


func world_direction_from_input(move_input: Vector2) -> Vector3:
	var yaw_basis := Basis(Vector3.UP, _yaw)
	var forward := -yaw_basis.z
	var right := yaw_basis.x
	return (right * move_input.x + forward * -move_input.y).limit_length(1.0)


func set_motion_context(horizontal_velocity: Vector3, wish_direction: Vector3, move_strength: float) -> void:
	_horizontal_velocity = Vector3(horizontal_velocity.x, 0.0, horizontal_velocity.z)
	_wish_direction = Vector3(wish_direction.x, 0.0, wish_direction.z).limit_length(1.0)
	_move_strength = clampf(move_strength, 0.0, 1.0)


func set_traversal_context(state: StringName, travel_direction: Vector3, wall_normal: Vector3) -> void:
	_traversal_state = state
	_traversal_direction = Vector3(travel_direction.x, 0.0, travel_direction.z).limit_length(1.0)
	_traversal_wall_normal = Vector3(wall_normal.x, 0.0, wall_normal.z).limit_length(1.0)


func apply_look_delta(pixel_delta: Vector2) -> void:
	_apply_manual_orbit(
		-pixel_delta.x * tuning.touch_mouse_sensitivity,
		-pixel_delta.y * tuning.touch_mouse_sensitivity
	)


func request_recenter() -> void:
	_requested_recenter = true


func snap_to_target(world_direction: Vector3 = Vector3.FORWARD) -> void:
	var flat_direction := Vector3(world_direction.x, 0.0, world_direction.z)
	if flat_direction.is_zero_approx():
		flat_direction = Vector3.FORWARD
	_yaw = atan2(-flat_direction.x, -flat_direction.z)
	_pitch = deg_to_rad(tuning.default_pitch_degrees)
	_manual_look_idle = 0.0
	_requested_recenter = false
	_smoothed_look_ahead = Vector3.ZERO
	_traversal_state = &"idle"
	_traversal_direction = Vector3.ZERO
	_traversal_wall_normal = Vector3.ZERO
	_traversal_blend = 0.0
	if _target:
		global_position = _target.global_position + tuning.target_offset
	_apply_rotation()


func get_obstruction_ratio() -> float:
	return spring_arm.get_hit_length() / maxf(spring_arm.spring_length, 0.001)


func get_orbit_angles() -> Vector2:
	return Vector2(_yaw, _pitch)


func _read_controller_look(delta: float) -> void:
	var look_input := Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if look_input.length_squared() <= 0.01:
		return
	var radians_per_second := deg_to_rad(tuning.controller_degrees_per_second)
	_apply_manual_orbit(
		-look_input.x * radians_per_second * delta,
		-look_input.y * radians_per_second * delta
	)


func _apply_manual_orbit(yaw_delta: float, pitch_delta: float) -> void:
	_yaw += yaw_delta
	_pitch = clampf(
		_pitch + pitch_delta,
		deg_to_rad(tuning.minimum_pitch_degrees),
		deg_to_rad(tuning.maximum_pitch_degrees)
	)
	_manual_look_idle = 0.0
	_requested_recenter = false


func _update_recenter(delta: float) -> void:
	var should_recenter := _requested_recenter
	if _manual_look_idle >= tuning.automatic_recenter_delay and _move_strength >= tuning.recenter_move_threshold:
		should_recenter = true
	var recenter_direction := _wish_direction
	if _horizontal_velocity.length_squared() > 0.04:
		recenter_direction = _horizontal_velocity.normalized()
	if not should_recenter or recenter_direction.is_zero_approx():
		return
	var desired_yaw := atan2(-recenter_direction.x, -recenter_direction.z)
	var sharpness := tuning.requested_recenter_sharpness if _requested_recenter else tuning.automatic_recenter_sharpness
	var blend := 1.0 - exp(-sharpness * delta)
	_yaw = lerp_angle(_yaw, desired_yaw, blend)
	_pitch = lerpf(_pitch, deg_to_rad(tuning.default_pitch_degrees), blend)
	if _requested_recenter and absf(angle_difference(_yaw, desired_yaw)) < deg_to_rad(0.75):
		_requested_recenter = false


func _update_follow(delta: float) -> void:
	if not _target:
		return
	var speed_alpha := clampf(
		_horizontal_velocity.length() / tuning.speed_for_full_response,
		0.0,
		1.0
	)
	var look_ahead_target := _wish_direction * tuning.maximum_look_ahead * speed_alpha
	var traversal_active := _traversal_state != &"idle" and _traversal_state != &"traversal_recovery"
	var traversal_target_blend := 1.0 if traversal_active else 0.0
	var traversal_blend_step := 1.0 - exp(-tuning.traversal_response_sharpness * delta)
	_traversal_blend = lerpf(_traversal_blend, traversal_target_blend, traversal_blend_step)
	var traversal_offset := Vector3.ZERO
	if _traversal_state in [&"vertical_wall_run", &"wall_climb", &"mantle", &"ledge_grab", &"ledge_climb"]:
		traversal_offset.y += tuning.traversal_vertical_offset
	if not _traversal_direction.is_zero_approx():
		traversal_offset += _traversal_direction * tuning.traversal_direction_look_ahead
	if _traversal_state == &"wall_run" and not _traversal_wall_normal.is_zero_approx():
		traversal_offset += _traversal_wall_normal * tuning.traversal_wall_side_offset
	look_ahead_target += traversal_offset * _traversal_blend
	var look_ahead_blend := 1.0 - exp(-tuning.look_ahead_sharpness * delta)
	_smoothed_look_ahead = _smoothed_look_ahead.lerp(look_ahead_target, look_ahead_blend)
	var desired_position := _target.global_position + tuning.target_offset + _smoothed_look_ahead
	var follow_blend := 1.0 - exp(-tuning.follow_sharpness * delta)
	global_position = global_position.lerp(desired_position, follow_blend)


func _update_speed_response(delta: float) -> void:
	var speed_alpha := clampf(
		_horizontal_velocity.length() / tuning.speed_for_full_response,
		0.0,
		1.0
	)
	var desired_length := tuning.base_arm_length + tuning.maximum_speed_arm_extension * speed_alpha
	var desired_fov := tuning.base_field_of_view + tuning.maximum_speed_fov_addition * speed_alpha
	desired_length += tuning.traversal_arm_extension * _traversal_blend
	desired_fov += tuning.traversal_field_of_view_addition * _traversal_blend
	var blend := 1.0 - exp(-tuning.speed_response_sharpness * delta)
	spring_arm.spring_length = lerpf(spring_arm.spring_length, desired_length, blend)
	camera.fov = lerpf(camera.fov, desired_fov, blend)


func _apply_rotation() -> void:
	rotation = Vector3(_pitch, _yaw, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_mouse_looking = event.pressed
	elif event is InputEventMouseMotion and _mouse_looking:
		apply_look_delta(event.relative)
