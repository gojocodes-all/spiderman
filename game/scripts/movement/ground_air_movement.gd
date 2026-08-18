class_name GroundAirMovement
extends Node

@export var tuning: MovementTuning = preload("res://game/data/movement/default_movement_tuning.tres")

@onready var state_machine: MovementStateMachine = $StateMachine
@onready var step_up_solver: StepUpSolver = $StepUpSolver

var _configured_body_id := 0
var _burst_cooldown_remaining := 0.0
var _coyote_remaining := 0.0
var _jump_buffer_remaining := 0.0
var _airborne_time := 0.0
var _peak_downward_speed := 0.0


func simulate(
	body: CharacterBody3D,
	wish_direction: Vector3,
	jump_pressed: bool,
	sprint_requested: bool,
	walk_requested: bool,
	burst_pressed: bool,
	delta: float
) -> void:
	_configure_body_if_needed(body)
	_burst_cooldown_remaining = maxf(0.0, _burst_cooldown_remaining - delta)
	_jump_buffer_remaining = maxf(0.0, _jump_buffer_remaining - delta)
	_coyote_remaining = maxf(0.0, _coyote_remaining - delta)
	if jump_pressed:
		_jump_buffer_remaining = tuning.jump_buffer_time

	var grounded_before := body.is_on_floor()
	if grounded_before:
		_coyote_remaining = tuning.coyote_time
	else:
		_airborne_time += delta
		_peak_downward_speed = maxf(_peak_downward_speed, -body.velocity.y)

	var input_strength := clampf(wish_direction.length(), 0.0, 1.0)
	var wish_normal := wish_direction.normalized() if input_strength > tuning.input_deadzone else Vector3.ZERO
	_apply_horizontal_response(
		body,
		wish_normal,
		input_strength,
		sprint_requested,
		walk_requested,
		grounded_before,
		delta
	)

	var launched := _try_consume_jump(body)
	_apply_gravity(body, grounded_before, launched, delta)
	_apply_temporary_burst(body, wish_normal, burst_pressed)
	_peak_downward_speed = maxf(_peak_downward_speed, -body.velocity.y)

	var stepped_up := false
	var retained_step_velocity := Vector3.ZERO
	if grounded_before and not launched:
		var horizontal_motion := Vector3(body.velocity.x, 0.0, body.velocity.z) * delta
		stepped_up = step_up_solver.try_step(body, horizontal_motion, tuning)
		if stepped_up:
			retained_step_velocity = Vector3(body.velocity.x, 0.0, body.velocity.z)
			body.velocity.x = 0.0
			body.velocity.z = 0.0

	body.move_and_slide()
	if stepped_up:
		body.velocity.x = retained_step_velocity.x
		body.velocity.z = retained_step_velocity.z
	var grounded_after := body.is_on_floor()
	if not grounded_after and grounded_before:
		_airborne_time = delta
	if grounded_after:
		if not grounded_before and _airborne_time >= tuning.minimum_air_time_for_landing:
			state_machine.register_landing(_peak_downward_speed, tuning)
		_airborne_time = 0.0
		_peak_downward_speed = 0.0

	var horizontal_speed := Vector2(body.velocity.x, body.velocity.z).length()
	state_machine.update_state(
		grounded_after,
		body.velocity.y,
		horizontal_speed,
		input_strength,
		sprint_requested,
		walk_requested,
		tuning,
		delta
	)


func reset_runtime_state(body: CharacterBody3D) -> void:
	body.velocity = Vector3.ZERO
	_burst_cooldown_remaining = 0.0
	_coyote_remaining = 0.0
	_jump_buffer_remaining = 0.0
	_airborne_time = 0.0
	_peak_downward_speed = 0.0
	state_machine.reset()


func horizontal_speed(body: CharacterBody3D) -> float:
	return Vector2(body.velocity.x, body.velocity.z).length()


func _configure_body_if_needed(body: CharacterBody3D) -> void:
	if _configured_body_id == body.get_instance_id():
		return
	_configured_body_id = body.get_instance_id()
	body.floor_max_angle = deg_to_rad(tuning.maximum_slope_angle_degrees)
	body.floor_snap_length = tuning.floor_snap_length
	body.floor_stop_on_slope = true
	body.floor_constant_speed = true
	body.floor_block_on_wall = true
	body.safe_margin = tuning.collision_safe_margin
	body.max_slides = tuning.maximum_slide_collisions
	body.up_direction = Vector3.UP
	body.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED


func _apply_horizontal_response(
	body: CharacterBody3D,
	wish_normal: Vector3,
	input_strength: float,
	sprint_requested: bool,
	walk_requested: bool,
	grounded: bool,
	delta: float
) -> void:
	var horizontal_velocity := Vector3(body.velocity.x, 0.0, body.velocity.z)
	var control_scale := state_machine.movement_control_scale(tuning)
	var target_speed := tuning.ground_target_speed(input_strength, sprint_requested, walk_requested)
	var target_velocity := wish_normal * target_speed

	if grounded:
		target_velocity *= control_scale
		var acceleration := tuning.ground_deceleration
		if not wish_normal.is_zero_approx():
			acceleration = tuning.ground_acceleration
			if not horizontal_velocity.is_zero_approx():
				var direction_dot := horizontal_velocity.normalized().dot(wish_normal)
				if direction_dot < tuning.direction_change_dot_threshold:
					acceleration = tuning.direction_change_acceleration
		acceleration *= maxf(control_scale, 0.15)
		horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	else:
		if not wish_normal.is_zero_approx():
			target_velocity = target_velocity.limit_length(tuning.maximum_air_speed)
			var air_response := tuning.air_acceleration * tuning.air_control
			horizontal_velocity = horizontal_velocity.move_toward(target_velocity, air_response * delta)
		else:
			horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, tuning.air_drag * delta)

	body.velocity.x = horizontal_velocity.x
	body.velocity.z = horizontal_velocity.z


func _try_consume_jump(body: CharacterBody3D) -> bool:
	if _jump_buffer_remaining <= 0.0 or _coyote_remaining <= 0.0:
		return false
	if state_machine.jump_is_locked():
		return false
	body.velocity.y = tuning.jump_velocity
	_jump_buffer_remaining = 0.0
	_coyote_remaining = 0.0
	_airborne_time = 0.0
	_peak_downward_speed = 0.0
	state_machine.begin_jump(tuning)
	return true


func _apply_gravity(body: CharacterBody3D, grounded: bool, launched: bool, delta: float) -> void:
	if grounded and not launched:
		body.velocity.y = -tuning.grounded_stick_velocity
		return
	var multiplier := tuning.rising_gravity_multiplier if body.velocity.y > 0.0 else tuning.falling_gravity_multiplier
	body.velocity.y = maxf(
		-tuning.terminal_fall_speed,
		body.velocity.y - tuning.gravity * multiplier * delta
	)


func _apply_temporary_burst(body: CharacterBody3D, wish_normal: Vector3, burst_pressed: bool) -> void:
	if not burst_pressed or _burst_cooldown_remaining > 0.0:
		return
	var launch_direction := wish_normal
	if launch_direction.is_zero_approx():
		launch_direction = -body.global_transform.basis.z
	launch_direction.y = tuning.burst_upward_ratio
	body.velocity += launch_direction.normalized() * tuning.burst_impulse
	_burst_cooldown_remaining = tuning.burst_cooldown_seconds
