class_name ParkourTraversal
extends Node

signal traversal_started(action: StringName, surface: StringName)
signal traversal_finished(action: StringName, reason: StringName)

@export var tuning: TraversalTuning = preload("res://game/data/traversal/default_traversal_tuning.tres")

@onready var state_machine: TraversalStateMachine = $StateMachine
@onready var detector: TraversalSurfaceDetector = $SurfaceDetector

var last_action := &"none"
var last_exit_reason := &"none"
var selected_surface := StringName()
var current_wall_normal := Vector3.ZERO
var current_travel_direction := Vector3.ZERO
var wall_jump_chain_count := 0
var successful_action_count := 0
var aborted_action_count := 0

var _current_probe := TraversalProbeResult.new()
var _wall_speed := 0.0
var _vertical_speed := 0.0
var _vertical_start_height := 0.0
var _vertical_elapsed := 0.0
var _entry_horizontal_speed := 0.0
var _reference_gravity := 0.0
var _reattach_cooldown := 0.0
var _ledge_regrab_cooldown := 0.0
var _ledge_away_hold := 0.0
var _ledge_probe_accumulator := 0.0
var _scripted_start := Vector3.ZERO
var _scripted_target := Vector3.ZERO
var _scripted_lift_target := Vector3.ZERO
var _scripted_cross_target := Vector3.ZERO
var _ledge_hang_target := Vector3.ZERO
var _ledge_climb_target := Vector3.ZERO


func simulate(
	body: CharacterBody3D,
	wish_direction: Vector3,
	jump_pressed: bool,
	sprint_requested: bool,
	reference_gravity: float,
	delta: float
) -> bool:
	_reference_gravity = reference_gravity
	state_machine.tick(delta)
	_reattach_cooldown = maxf(0.0, _reattach_cooldown - delta)
	_ledge_regrab_cooldown = maxf(0.0, _ledge_regrab_cooldown - delta)
	if body.is_on_floor():
		wall_jump_chain_count = 0

	if state_machine.current_state == TraversalStateMachine.TraversalState.RECOVERY:
		if state_machine.state_elapsed >= tuning.traversal_recovery_time:
			state_machine.transition(TraversalStateMachine.TraversalState.IDLE, &"recovery_complete")
		return false

	if state_machine.owns_character_motion():
		return _simulate_active(body, wish_direction, jump_pressed, delta)

	if state_machine.current_state != TraversalStateMachine.TraversalState.IDLE:
		state_machine.force_idle(&"inactive_normalization")
	if _try_begin_contextual(body, wish_direction, sprint_requested):
		return true
	return false


func reset_runtime_state(body: CharacterBody3D) -> void:
	state_machine.reset()
	last_action = &"none"
	last_exit_reason = &"none"
	selected_surface = StringName()
	current_wall_normal = Vector3.ZERO
	current_travel_direction = Vector3.ZERO
	wall_jump_chain_count = 0
	successful_action_count = 0
	aborted_action_count = 0
	_wall_speed = 0.0
	_vertical_speed = 0.0
	_vertical_start_height = body.global_position.y
	_vertical_elapsed = 0.0
	_entry_horizontal_speed = 0.0
	_reference_gravity = 0.0
	_reattach_cooldown = 0.0
	_ledge_regrab_cooldown = 0.0
	_ledge_away_hold = 0.0
	_ledge_probe_accumulator = 0.0
	_scripted_start = Vector3.ZERO
	_scripted_target = Vector3.ZERO
	_scripted_lift_target = Vector3.ZERO
	_scripted_cross_target = Vector3.ZERO
	_ledge_hang_target = Vector3.ZERO
	_ledge_climb_target = Vector3.ZERO


func current_probe() -> TraversalProbeResult:
	return _current_probe


func state_name() -> StringName:
	return state_machine.state_name()


func owns_facing() -> bool:
	return state_machine.owns_character_motion()


func facing_direction() -> Vector3:
	match state_machine.current_state:
		TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, TraversalStateMachine.TraversalState.WALL_CLIMB, TraversalStateMachine.TraversalState.LEDGE_GRAB, TraversalStateMachine.TraversalState.LEDGE_CLIMB:
			return -current_wall_normal
		_:
			return current_travel_direction


func visual_lean_degrees() -> Vector2:
	match state_machine.current_state:
		TraversalStateMachine.TraversalState.WALL_RUN:
			var side := signf(current_wall_normal.dot(current_travel_direction.cross(Vector3.UP)))
			return Vector2(0.0, tuning.wall_run_visual_lean_degrees * side)
		TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, TraversalStateMachine.TraversalState.WALL_CLIMB:
			return Vector2(-tuning.vertical_visual_lean_degrees, 0.0)
		_:
			return Vector2.ZERO


func _try_begin_contextual(
	body: CharacterBody3D,
	wish_direction: Vector3,
	_sprint_requested: bool
) -> bool:
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z)
	if wish.length_squared() < 0.01:
		return false
	wish = wish.normalized()
	var horizontal_velocity := Vector3(body.velocity.x, 0.0, body.velocity.z)
	var horizontal_speed := horizontal_velocity.length()
	var probe_distance := maxf(tuning.forward_probe_distance, tuning.mantle_detection_range)
	_current_probe = detector.probe(body, wish, tuning, probe_distance, true)
	if not _current_probe.has_obstacle or not _current_probe.wall_is_usable:
		return false

	if body.is_on_floor():
		if _can_vault(horizontal_speed):
			_begin_vault(body, wish)
			return true
		return false

	if body.velocity.y > 0.0 and _can_mantle(body, horizontal_speed):
		_begin_mantle(body, wish)
		return true
	if _can_grab_ledge(body):
		_begin_ledge_grab(body)
		return true
	if _can_mantle(body, horizontal_speed):
		_begin_mantle(body, wish)
		return true

	if not _current_probe.has_wall or _reattach_cooldown > 0.0:
		return false
	if wall_jump_chain_count >= tuning.maximum_wall_jump_chain:
		return false
	var travel_direction := horizontal_velocity.normalized() if horizontal_speed > 0.1 else wish
	var approach_dot := maxf(travel_direction.dot(-_current_probe.wall_normal), wish.dot(-_current_probe.wall_normal))
	if approach_dot >= tuning.vertical_minimum_direct_approach_dot and horizontal_speed >= tuning.vertical_minimum_entry_speed:
		_begin_vertical_wall_run(body, wish)
		return true
	var tangent_velocity := horizontal_velocity.slide(_current_probe.wall_normal)
	var tangent_speed := tangent_velocity.length()
	if (
		horizontal_speed >= tuning.wall_run_minimum_entry_speed
		and tangent_speed >= tuning.wall_run_minimum_entry_speed * tuning.wall_run_minimum_tangent_speed_ratio
		and approach_dot >= tuning.wall_run_minimum_approach_dot
		and approach_dot < tuning.wall_run_maximum_direct_approach_dot
	):
		_begin_wall_run(body, wish)
		return true
	return false


func _can_vault(horizontal_speed: float) -> bool:
	return (
		horizontal_speed >= tuning.vault_minimum_speed
		and _current_probe.has_top
		and _current_probe.obstacle_height >= tuning.vault_minimum_height
		and _current_probe.obstacle_height <= tuning.vault_maximum_height
		and _current_probe.vault_landing_found
	)


func _can_mantle(body: CharacterBody3D, horizontal_speed: float) -> bool:
	if not _current_probe.has_top or not _current_probe.destination_clear:
		return false
	if horizontal_speed < tuning.mantle_minimum_approach_speed:
		return false
	if _current_probe.obstacle_height < tuning.mantle_minimum_height or _current_probe.obstacle_height > tuning.mantle_maximum_height:
		return false
	var ledge_relative_to_center := _current_probe.top_point.y - body.global_position.y
	return ledge_relative_to_center <= detector.body_half_height() + tuning.ledge_vertical_tolerance


func _can_grab_ledge(body: CharacterBody3D) -> bool:
	if _ledge_regrab_cooldown > 0.0 or not _current_probe.has_top or not _current_probe.destination_clear:
		return false
	if body.velocity.y > tuning.ledge_maximum_rising_speed:
		return false
	var hand_height := body.global_position.y + detector.body_half_height() * tuning.ledge_hand_height_fraction
	return absf(_current_probe.top_point.y - hand_height) <= tuning.ledge_vertical_tolerance


func _begin_wall_run(body: CharacterBody3D, wish: Vector3) -> void:
	current_wall_normal = _current_probe.wall_normal
	var tangent := current_wall_normal.cross(Vector3.UP).normalized()
	var horizontal_velocity := Vector3(body.velocity.x, 0.0, body.velocity.z)
	var reference := horizontal_velocity if horizontal_velocity.length_squared() > 0.04 else wish
	if tangent.dot(reference) < 0.0:
		tangent = -tangent
	current_travel_direction = tangent
	_wall_speed = clampf(
		maxf(horizontal_velocity.slide(current_wall_normal).length(), tuning.wall_run_minimum_entry_speed),
		tuning.wall_run_minimum_entry_speed,
		tuning.wall_run_maximum_entry_speed
	)
	selected_surface = _current_probe.surface_name
	_transition_started(TraversalStateMachine.TraversalState.WALL_RUN, &"angled_wall_entry")


func _begin_vertical_wall_run(body: CharacterBody3D, wish: Vector3) -> void:
	current_wall_normal = _current_probe.wall_normal
	current_travel_direction = Vector3.UP
	_vertical_speed = maxf(body.velocity.y, tuning.vertical_initial_upward_speed)
	_vertical_start_height = body.global_position.y
	_vertical_elapsed = 0.0
	_entry_horizontal_speed = Vector2(body.velocity.x, body.velocity.z).length()
	selected_surface = _current_probe.surface_name
	_transition_started(TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, &"direct_wall_entry")


func _begin_vault(body: CharacterBody3D, wish: Vector3) -> void:
	_scripted_start = body.global_position
	_scripted_target = _current_probe.vault_target
	var clearance_height := _current_probe.top_point.y + detector.body_half_height() + tuning.destination_clearance
	_scripted_lift_target = Vector3(
		_scripted_start.x,
		maxf(_scripted_start.y + tuning.vault_apex_clearance, clearance_height),
		_scripted_start.z
	)
	_scripted_cross_target = Vector3(
		_scripted_target.x,
		_scripted_lift_target.y,
		_scripted_target.z
	)
	current_travel_direction = wish
	current_wall_normal = _current_probe.wall_normal
	_entry_horizontal_speed = Vector2(body.velocity.x, body.velocity.z).length()
	selected_surface = _current_probe.surface_name
	body.velocity = Vector3.ZERO
	_transition_started(TraversalStateMachine.TraversalState.VAULT, &"contextual_low_obstacle")


func _begin_mantle(body: CharacterBody3D, wish: Vector3) -> void:
	_scripted_start = body.global_position
	_scripted_target = _current_probe.mantle_target
	_scripted_lift_target = Vector3(
		_scripted_start.x,
		_scripted_target.y + tuning.mantle_lift_clearance,
		_scripted_start.z
	)
	current_travel_direction = wish
	current_wall_normal = _current_probe.wall_normal
	_entry_horizontal_speed = Vector2(body.velocity.x, body.velocity.z).length()
	selected_surface = _current_probe.surface_name
	body.velocity = Vector3.ZERO
	_transition_started(TraversalStateMachine.TraversalState.MANTLE, &"reachable_clear_top")


func _begin_ledge_grab(body: CharacterBody3D) -> void:
	_scripted_start = body.global_position
	_ledge_hang_target = _current_probe.hang_target
	_ledge_climb_target = _current_probe.mantle_target
	current_wall_normal = _current_probe.wall_normal
	current_travel_direction = Vector3.ZERO
	_entry_horizontal_speed = Vector2(body.velocity.x, body.velocity.z).length()
	selected_surface = _current_probe.surface_name
	_ledge_away_hold = 0.0
	_ledge_probe_accumulator = 0.0
	body.velocity = Vector3.ZERO
	_transition_started(TraversalStateMachine.TraversalState.LEDGE_GRAB, &"falling_near_ledge")


func _simulate_active(
	body: CharacterBody3D,
	wish_direction: Vector3,
	jump_pressed: bool,
	delta: float
) -> bool:
	match state_machine.current_state:
		TraversalStateMachine.TraversalState.WALL_RUN:
			_simulate_wall_run(body, wish_direction, jump_pressed, delta)
		TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, TraversalStateMachine.TraversalState.WALL_CLIMB:
			_simulate_vertical(body, wish_direction, jump_pressed, delta)
		TraversalStateMachine.TraversalState.WALL_JUMP:
			_simulate_wall_jump(body, wish_direction, delta)
		TraversalStateMachine.TraversalState.VAULT:
			_simulate_vault(body)
		TraversalStateMachine.TraversalState.MANTLE:
			_simulate_mantle(body)
		TraversalStateMachine.TraversalState.LEDGE_GRAB:
			_simulate_ledge_grab(body, wish_direction, jump_pressed, delta)
		TraversalStateMachine.TraversalState.LEDGE_CLIMB:
			_simulate_ledge_climb(body)
		_:
			return false
	return true


func _simulate_wall_run(body: CharacterBody3D, wish_direction: Vector3, jump_pressed: bool, delta: float) -> void:
	if jump_pressed:
		_begin_wall_jump(body, wish_direction, &"wall_run_jump")
		return
	_current_probe = detector.probe(body, -current_wall_normal, tuning, tuning.forward_probe_distance + tuning.active_wall_probe_extra_distance, true)
	if not _active_wall_probe_is_valid():
		_finish_to_recovery(&"wall_ended", true)
		return
	if _normal_change_exceeds_limit(_current_probe.wall_normal):
		_finish_to_recovery(&"wall_angle_changed", true)
		return
	current_wall_normal = _current_probe.wall_normal
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z)
	if not wish.is_zero_approx() and wish.normalized().dot(current_wall_normal) >= tuning.wall_run_exit_away_dot:
		_finish_to_recovery(&"input_away_from_wall", true)
		return
	if state_machine.state_elapsed >= tuning.wall_run_maximum_duration:
		_finish_to_recovery(&"wall_run_duration", true)
		return
	var tangent := current_wall_normal.cross(Vector3.UP).normalized()
	if tangent.dot(current_travel_direction) < 0.0:
		tangent = -tangent
	if not wish.is_zero_approx() and absf(wish.normalized().dot(tangent)) >= tuning.wall_run_minimum_tangent_input:
		if wish.normalized().dot(tangent) < 0.0:
			tangent = -tangent
	current_travel_direction = tangent
	_wall_speed = maxf(tuning.wall_run_minimum_exit_speed, _wall_speed - tuning.wall_run_speed_loss * delta)
	if _wall_speed <= tuning.wall_run_minimum_exit_speed + 0.01:
		_finish_to_recovery(&"wall_run_speed_exhausted", true)
		return
	var vertical_speed := body.velocity.y - _reference_gravity * tuning.wall_run_gravity_multiplier * delta
	var adhesion_speed := clampf(
		tuning.wall_run_minimum_adhesion_speed + tuning.wall_run_adhesion_force * delta,
		tuning.wall_run_minimum_adhesion_speed,
		tuning.wall_run_maximum_adhesion_speed
	)
	body.velocity = tangent * _wall_speed + Vector3.UP * vertical_speed - current_wall_normal * adhesion_speed
	body.move_and_slide()


func _simulate_vertical(body: CharacterBody3D, wish_direction: Vector3, jump_pressed: bool, delta: float) -> void:
	_vertical_elapsed += delta
	if jump_pressed:
		_begin_wall_jump(body, wish_direction, &"vertical_wall_jump")
		return
	_current_probe = detector.probe(body, -current_wall_normal, tuning, tuning.forward_probe_distance + tuning.active_wall_probe_extra_distance, true)
	if not _active_wall_probe_is_valid():
		_finish_to_recovery(&"vertical_wall_ended", true)
		return
	current_wall_normal = _current_probe.wall_normal
	if _current_probe.has_top and _current_probe.destination_clear:
		var hand_height := body.global_position.y + detector.body_half_height() * tuning.ledge_hand_height_fraction
		if absf(_current_probe.top_point.y - hand_height) <= tuning.ledge_vertical_tolerance:
			_begin_mantle_from_active(body)
			return
	if (
		state_machine.current_state == TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN
		and _vertical_elapsed >= tuning.vertical_run_to_climb_time
	):
		state_machine.transition(TraversalStateMachine.TraversalState.WALL_CLIMB, &"vertical_speed_decay")
	if _vertical_elapsed >= tuning.vertical_maximum_duration:
		_finish_to_recovery(&"vertical_duration", true)
		return
	if body.global_position.y - _vertical_start_height >= tuning.vertical_distance_limit:
		_finish_to_recovery(&"vertical_distance_limit", true)
		return
	_vertical_speed -= tuning.vertical_gravity * delta
	if _vertical_speed <= tuning.vertical_exit_speed:
		_finish_to_recovery(&"vertical_momentum_exhausted", true)
		return
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z)
	var tangent := current_wall_normal.cross(Vector3.UP).normalized()
	var lateral := tangent * clampf(wish.dot(tangent), -1.0, 1.0) * tuning.vertical_lateral_speed
	var adhesion_speed := clampf(
		tuning.vertical_minimum_adhesion_speed + tuning.vertical_adhesion_force * delta,
		tuning.vertical_minimum_adhesion_speed,
		tuning.vertical_maximum_adhesion_speed
	)
	body.velocity = Vector3.UP * _vertical_speed + lateral - current_wall_normal * adhesion_speed
	body.move_and_slide()


func _simulate_wall_jump(body: CharacterBody3D, wish_direction: Vector3, delta: float) -> void:
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z)
	if not wish.is_zero_approx():
		var horizontal := Vector3(body.velocity.x, 0.0, body.velocity.z)
		horizontal = horizontal.move_toward(wish.normalized() * horizontal.length(), tuning.wall_jump_input_influence * delta)
		body.velocity.x = horizontal.x
		body.velocity.z = horizontal.z
	body.velocity.y -= tuning.wall_jump_gravity * delta
	body.move_and_slide()
	if body.is_on_floor():
		_finish_to_recovery(&"wall_jump_landed", false)
	elif state_machine.state_elapsed >= tuning.wall_jump_motion_lock:
		state_machine.transition(TraversalStateMachine.TraversalState.IDLE, &"wall_jump_air_control")
		last_exit_reason = &"wall_jump_air_control"


func _simulate_vault(body: CharacterBody3D) -> void:
	var progress := clampf(state_machine.state_elapsed / tuning.vault_duration, 0.0, 1.0)
	var desired: Vector3
	if progress < tuning.vault_lift_fraction:
		var lift_alpha := progress / maxf(tuning.vault_lift_fraction, 0.001)
		lift_alpha = lift_alpha * lift_alpha * (3.0 - 2.0 * lift_alpha)
		desired = _scripted_start.lerp(_scripted_lift_target, lift_alpha)
	elif progress < tuning.vault_cross_fraction:
		var cross_alpha := (progress - tuning.vault_lift_fraction) / maxf(tuning.vault_cross_fraction - tuning.vault_lift_fraction, 0.001)
		cross_alpha = cross_alpha * cross_alpha * (3.0 - 2.0 * cross_alpha)
		desired = _scripted_lift_target.lerp(_scripted_cross_target, cross_alpha)
	else:
		var land_alpha := (progress - tuning.vault_cross_fraction) / maxf(1.0 - tuning.vault_cross_fraction, 0.001)
		land_alpha = land_alpha * land_alpha * (3.0 - 2.0 * land_alpha)
		desired = _scripted_cross_target.lerp(_scripted_target, land_alpha)
	if not _move_scripted(body, desired, progress):
		return
	if progress >= 1.0:
		_complete_scripted(body, tuning.vault_momentum_preservation, &"vault_complete")


func _simulate_mantle(body: CharacterBody3D) -> void:
	var progress := clampf(state_machine.state_elapsed / tuning.mantle_duration, 0.0, 1.0)
	var desired: Vector3
	if progress < tuning.mantle_lift_fraction:
		var lift_alpha := progress / maxf(tuning.mantle_lift_fraction, 0.001)
		lift_alpha = lift_alpha * lift_alpha * (3.0 - 2.0 * lift_alpha)
		desired = _scripted_start.lerp(_scripted_lift_target, lift_alpha)
	else:
		var cross_alpha := (progress - tuning.mantle_lift_fraction) / maxf(1.0 - tuning.mantle_lift_fraction, 0.001)
		cross_alpha = cross_alpha * cross_alpha * (3.0 - 2.0 * cross_alpha)
		desired = _scripted_lift_target.lerp(_scripted_target, cross_alpha)
	if not _move_scripted(body, desired, progress):
		return
	if progress >= 1.0:
		_complete_scripted(body, tuning.mantle_momentum_preservation, &"mantle_complete")


func _simulate_ledge_grab(
	body: CharacterBody3D,
	wish_direction: Vector3,
	jump_pressed: bool,
	delta: float
) -> void:
	body.velocity = Vector3.ZERO
	if state_machine.state_elapsed <= tuning.ledge_snap_duration:
		var snap_alpha := clampf(state_machine.state_elapsed / tuning.ledge_snap_duration, 0.0, 1.0)
		var desired := _scripted_start.lerp(_ledge_hang_target, snap_alpha)
		_move_scripted(body, desired, snap_alpha, false)
		return
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z)
	if jump_pressed:
		if not wish.is_zero_approx() and wish.normalized().dot(current_wall_normal) >= tuning.ledge_drop_away_dot:
			_begin_wall_jump(body, wish, &"ledge_jump_away")
		else:
			_begin_ledge_climb(body)
		return
	if not wish.is_zero_approx() and wish.normalized().dot(current_wall_normal) >= tuning.ledge_drop_away_dot:
		_ledge_away_hold += delta
	else:
		_ledge_away_hold = 0.0
	if _ledge_away_hold >= tuning.ledge_drop_hold_time:
		body.velocity = current_wall_normal * tuning.ledge_drop_outward_speed + Vector3.DOWN * tuning.ledge_drop_speed
		_ledge_regrab_cooldown = tuning.ledge_regrab_cooldown
		_finish_to_recovery(&"ledge_drop", false)
		return
	var tangent := current_wall_normal.cross(Vector3.UP).normalized()
	var side_input := clampf(wish.dot(tangent), -1.0, 1.0)
	if absf(side_input) > tuning.ledge_shimmy_input_deadzone:
		body.move_and_collide(tangent * side_input * tuning.ledge_shimmy_speed * delta)
	_ledge_probe_accumulator += delta
	if _ledge_probe_accumulator >= tuning.ledge_validation_interval:
		_ledge_probe_accumulator = 0.0
		_current_probe = detector.probe(body, -current_wall_normal, tuning, tuning.ledge_grab_range, true)
		if not _current_probe.has_obstacle or not _current_probe.wall_is_usable:
			body.velocity = Vector3.DOWN * tuning.ledge_drop_speed
			_finish_to_recovery(&"ledge_surface_lost", true)


func _begin_ledge_climb(body: CharacterBody3D) -> void:
	_scripted_start = body.global_position
	_scripted_target = _ledge_climb_target
	_scripted_lift_target = Vector3(
		_scripted_start.x,
		_scripted_target.y + tuning.mantle_lift_clearance,
		_scripted_start.z
	)
	state_machine.transition(TraversalStateMachine.TraversalState.LEDGE_CLIMB, &"jump_to_climb")
	last_action = &"ledge_climb"
	emit_signal(&"traversal_started", last_action, selected_surface)


func _simulate_ledge_climb(body: CharacterBody3D) -> void:
	var progress := clampf(state_machine.state_elapsed / tuning.ledge_climb_duration, 0.0, 1.0)
	var desired: Vector3
	if progress < tuning.mantle_lift_fraction:
		var lift_alpha := progress / maxf(tuning.mantle_lift_fraction, 0.001)
		desired = _scripted_start.lerp(_scripted_lift_target, lift_alpha)
	else:
		var cross_alpha := (progress - tuning.mantle_lift_fraction) / maxf(1.0 - tuning.mantle_lift_fraction, 0.001)
		desired = _scripted_lift_target.lerp(_scripted_target, cross_alpha)
	if not _move_scripted(body, desired, progress):
		return
	if progress >= 1.0:
		_complete_scripted(body, tuning.mantle_momentum_preservation, &"ledge_climb_complete")


func _begin_mantle_from_active(body: CharacterBody3D) -> void:
	_scripted_start = body.global_position
	_scripted_target = _current_probe.mantle_target
	_scripted_lift_target = Vector3(
		_scripted_start.x,
		_scripted_target.y + tuning.mantle_lift_clearance,
		_scripted_start.z
	)
	_entry_horizontal_speed = maxf(_wall_speed, _entry_horizontal_speed)
	current_travel_direction = -current_wall_normal
	body.velocity = Vector3.ZERO
	state_machine.transition(TraversalStateMachine.TraversalState.MANTLE, &"wall_reached_clear_top")
	last_action = &"mantle"
	emit_signal(&"traversal_started", last_action, selected_surface)


func _begin_wall_jump(body: CharacterBody3D, wish_direction: Vector3, reason: StringName) -> void:
	var tangent_velocity := Vector3(body.velocity.x, 0.0, body.velocity.z).slide(current_wall_normal)
	var upward_scale := 1.0
	if wall_jump_chain_count >= tuning.maximum_wall_jump_chain:
		upward_scale = tuning.exhausted_chain_upward_scale
	var wish := Vector3(wish_direction.x, 0.0, wish_direction.z).limit_length(1.0)
	body.velocity = (
		current_wall_normal * tuning.wall_jump_outward_speed
		+ Vector3.UP * tuning.wall_jump_upward_speed * upward_scale
		+ tangent_velocity * tuning.wall_jump_tangent_preservation
		+ wish * tuning.wall_jump_input_influence
	)
	current_travel_direction = Vector3(body.velocity.x, 0.0, body.velocity.z).normalized()
	wall_jump_chain_count += 1
	_reattach_cooldown = tuning.wall_jump_reattach_cooldown
	state_machine.transition(TraversalStateMachine.TraversalState.WALL_JUMP, reason)
	last_action = &"wall_jump"
	emit_signal(&"traversal_started", last_action, selected_surface)


func _move_scripted(body: CharacterBody3D, desired: Vector3, progress: float, abort_on_collision: bool = true) -> bool:
	var motion := desired - body.global_position
	if motion.length_squared() <= 0.0000001:
		return true
	var collision := body.move_and_collide(motion)
	if collision and abort_on_collision and progress < tuning.scripted_collision_completion_threshold:
		body.velocity = current_travel_direction * _entry_horizontal_speed * tuning.scripted_abort_momentum_preservation
		_finish_to_recovery(&"scripted_path_blocked", true)
		return false
	return true


func _complete_scripted(body: CharacterBody3D, momentum_scale: float, reason: StringName) -> void:
	body.velocity = current_travel_direction * _entry_horizontal_speed * momentum_scale
	successful_action_count += 1
	_finish_to_recovery(reason, false)


func _active_wall_probe_is_valid() -> bool:
	return _current_probe.has_wall and _current_probe.wall_is_usable


func _normal_change_exceeds_limit(next_normal: Vector3) -> bool:
	var dot_value := clampf(current_wall_normal.dot(next_normal), -1.0, 1.0)
	return rad_to_deg(acos(dot_value)) > tuning.wall_run_maximum_normal_change_degrees


func _transition_started(next_state: TraversalStateMachine.TraversalState, reason: StringName) -> void:
	state_machine.transition(next_state, reason)
	last_action = state_machine.state_name()
	last_exit_reason = &"none"
	emit_signal(&"traversal_started", last_action, selected_surface)


func _finish_to_recovery(reason: StringName, aborted: bool) -> void:
	var finished_action := last_action
	last_exit_reason = reason
	if aborted:
		aborted_action_count += 1
	if state_machine.current_state != TraversalStateMachine.TraversalState.RECOVERY:
		state_machine.transition(TraversalStateMachine.TraversalState.RECOVERY, reason)
	emit_signal(&"traversal_finished", finished_action, reason)
