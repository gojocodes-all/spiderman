class_name StepUpSolver
extends Node

var _parameters := PhysicsTestMotionParameters3D.new()
var _forward_result := PhysicsTestMotionResult3D.new()
var _raised_forward_result := PhysicsTestMotionResult3D.new()
var _ray_parameters := PhysicsRayQueryParameters3D.new()
var _excluded_body_id := 0

var probe_attempt_count := 0
var successful_step_count := 0
var raised_clearance_rejection_count := 0
var height_rejection_count := 0
var surface_rejection_count := 0
var last_probe_position := Vector3.ZERO
var solver_call_count := 0
var no_wall_rejection_count := 0
var small_motion_rejection_count := 0


func reset_diagnostics() -> void:
	probe_attempt_count = 0
	successful_step_count = 0
	raised_clearance_rejection_count = 0
	height_rejection_count = 0
	surface_rejection_count = 0
	last_probe_position = Vector3.ZERO
	solver_call_count = 0
	no_wall_rejection_count = 0
	small_motion_rejection_count = 0


func try_step(
	body: CharacterBody3D,
	horizontal_motion: Vector3,
	tuning: MovementTuning
) -> bool:
	solver_call_count += 1
	if not body.is_on_floor():
		return false
	if not body.is_on_wall():
		no_wall_rejection_count += 1
		return false
	if horizontal_motion.length() < tuning.minimum_step_forward_motion:
		small_motion_rejection_count += 1
		return false
	_configure_ray_if_needed(body)

	_parameters.margin = tuning.collision_safe_margin
	_parameters.max_collisions = 2
	_parameters.recovery_as_collision = true
	_parameters.from = body.global_transform
	_parameters.motion = horizontal_motion
	if not PhysicsServer3D.body_test_motion(body.get_rid(), _parameters, _forward_result):
		return false
	probe_attempt_count += 1
	last_probe_position = body.global_position

	var forward_direction := horizontal_motion.normalized()
	var forward_step_motion := forward_direction * tuning.step_surface_probe_forward
	var raised_transform := body.global_transform.translated(Vector3.UP * tuning.maximum_step_height)
	_parameters.from = raised_transform
	_parameters.motion = forward_step_motion
	if PhysicsServer3D.body_test_motion(body.get_rid(), _parameters, _raised_forward_result):
		raised_clearance_rejection_count += 1
		return false

	var cast_height := tuning.maximum_step_height + tuning.step_down_probe
	var current_floor_height := _sample_floor_height(
		body,
		body.global_position + Vector3.UP * cast_height,
		cast_height + tuning.step_floor_probe_depth
	)
	var sample_position := body.global_position
	sample_position += forward_direction * tuning.step_surface_probe_forward
	var target_floor_height := _sample_floor_height(
		body,
		sample_position + Vector3.UP * cast_height,
		cast_height + tuning.step_floor_probe_depth
	)
	if is_nan(current_floor_height) or is_nan(target_floor_height):
		surface_rejection_count += 1
		return false
	var required_step_height := target_floor_height - current_floor_height
	if required_step_height <= tuning.step_clearance:
		surface_rejection_count += 1
		return false
	if required_step_height > tuning.maximum_step_height + tuning.step_clearance:
		height_rejection_count += 1
		return false
	body.global_position += forward_step_motion
	body.global_position.y += required_step_height + tuning.step_clearance
	successful_step_count += 1
	return true


func _configure_ray_if_needed(body: CharacterBody3D) -> void:
	if _excluded_body_id == body.get_instance_id():
		return
	_excluded_body_id = body.get_instance_id()
	_ray_parameters.exclude = [body.get_rid()]
	_ray_parameters.collision_mask = body.collision_mask
	_ray_parameters.collide_with_areas = false
	_ray_parameters.collide_with_bodies = true
	_ray_parameters.hit_from_inside = false


func _sample_floor_height(body: CharacterBody3D, ray_start: Vector3, ray_length: float) -> float:
	_ray_parameters.from = ray_start
	_ray_parameters.to = ray_start + Vector3.DOWN * ray_length
	var hit := body.get_world_3d().direct_space_state.intersect_ray(_ray_parameters)
	if hit.is_empty():
		return NAN
	var normal: Vector3 = hit["normal"]
	if normal.dot(Vector3.UP) <= 0.01:
		return NAN
	var position: Vector3 = hit["position"]
	return position.y
