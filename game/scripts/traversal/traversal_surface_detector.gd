class_name TraversalSurfaceDetector
extends Node

var _ray_parameters := PhysicsRayQueryParameters3D.new()
var _shape_parameters := PhysicsShapeQueryParameters3D.new()
var _result := TraversalProbeResult.new()
var _excluded_body_id := 0
var _body_half_height := 0.95
var _body_radius := 0.43
var _query_count := 0

var probe_call_count := 0
var ray_query_count := 0
var clearance_query_count := 0
var invalid_surface_rejection_count := 0
var geometry_rejection_count := 0
var peak_queries_per_probe := 0
var last_queries_per_probe := 0


func reset_diagnostics() -> void:
	probe_call_count = 0
	ray_query_count = 0
	clearance_query_count = 0
	invalid_surface_rejection_count = 0
	geometry_rejection_count = 0
	peak_queries_per_probe = 0
	last_queries_per_probe = 0


func probe(
	body: CharacterBody3D,
	world_direction: Vector3,
	tuning: TraversalTuning,
	distance_override: float = -1.0,
	include_top: bool = true
) -> TraversalProbeResult:
	_result.reset()
	probe_call_count += 1
	_query_count = 0
	_configure_for_body(body, tuning)
	var direction := Vector3(world_direction.x, 0.0, world_direction.z)
	if direction.length_squared() < 0.0001:
		_finish_probe()
		return _result
	direction = direction.normalized()
	var distance := tuning.forward_probe_distance if distance_override <= 0.0 else distance_override

	_result.lower_ray_start = body.global_position + Vector3.UP * tuning.lower_probe_height
	_result.lower_ray_end = _result.lower_ray_start + direction * distance
	_result.upper_ray_start = body.global_position + Vector3.UP * tuning.upper_probe_height
	_result.upper_ray_end = _result.upper_ray_start + direction * distance
	var lower_hit := _cast_ray(body, _result.lower_ray_start, _result.lower_ray_end, tuning)
	var upper_hit := _cast_ray(body, _result.upper_ray_start, _result.upper_ray_end, tuning)
	var primary_hit: Dictionary = lower_hit if not lower_hit.is_empty() else upper_hit
	if primary_hit.is_empty():
		_finish_probe()
		return _result

	_result.has_obstacle = true
	_result.wall_point = primary_hit["position"]
	_result.wall_normal = (primary_hit["normal"] as Vector3).normalized()
	_result.wall_distance = body.global_position.distance_to(_result.wall_point)
	_result.wall_angle_degrees = rad_to_deg(acos(clampf(_result.wall_normal.dot(Vector3.UP), -1.0, 1.0)))
	_result.wall_collider = primary_hit["collider"] as CollisionObject3D
	if _result.wall_collider:
		_result.surface_name = StringName(_result.wall_collider.name)
	_result.wall_direction = _result.wall_normal.cross(Vector3.UP).normalized()
	_result.wall_is_usable = _is_usable_surface(_result.wall_collider)
	if not _result.wall_is_usable:
		invalid_surface_rejection_count += 1

	var probes_match := false
	if not lower_hit.is_empty() and not upper_hit.is_empty():
		var lower_collider := lower_hit["collider"] as CollisionObject3D
		var upper_collider := upper_hit["collider"] as CollisionObject3D
		var lower_normal: Vector3 = lower_hit["normal"]
		var upper_normal: Vector3 = upper_hit["normal"]
		probes_match = lower_collider == upper_collider
		probes_match = probes_match and lower_normal.normalized().dot(upper_normal.normalized()) >= tuning.matching_wall_normal_dot
		probes_match = probes_match and absf(tuning.upper_probe_height - tuning.lower_probe_height) >= tuning.minimum_wall_probe_separation
	_result.has_wall = probes_match and absf(_result.wall_normal.dot(Vector3.UP)) <= tuning.maximum_wall_up_dot
	if probes_match and not _result.has_wall:
		geometry_rejection_count += 1

	if include_top and _result.wall_is_usable:
		_detect_top_and_targets(body, direction, tuning)
	_finish_probe()
	return _result


func is_position_clear(body: CharacterBody3D, target_position: Vector3, tuning: TraversalTuning) -> bool:
	_configure_for_body(body, tuning)
	clearance_query_count += 1
	_shape_parameters.transform = Transform3D(body.global_transform.basis, target_position)
	_shape_parameters.margin = tuning.destination_clearance * tuning.destination_shape_margin_scale
	return body.get_world_3d().direct_space_state.intersect_shape(_shape_parameters, 1).is_empty()


func body_half_height() -> float:
	return _body_half_height


func body_radius() -> float:
	return _body_radius


func _detect_top_and_targets(body: CharacterBody3D, direction: Vector3, tuning: TraversalTuning) -> void:
	var foot_height := body.global_position.y - _body_half_height
	var top_sample := _result.wall_point - _result.wall_normal * tuning.top_probe_inset
	_result.top_ray_start = Vector3(
		top_sample.x,
		foot_height + tuning.mantle_maximum_height + _body_half_height + tuning.top_probe_above_body_margin,
		top_sample.z
	)
	_result.top_ray_end = Vector3(top_sample.x, foot_height - tuning.top_probe_below_feet, top_sample.z)
	var top_hit := _cast_ray(body, _result.top_ray_start, _result.top_ray_end, tuning)
	if top_hit.is_empty():
		return
	var top_collider := top_hit["collider"] as CollisionObject3D
	if top_collider != _result.wall_collider:
		geometry_rejection_count += 1
		return
	var top_normal: Vector3 = top_hit["normal"]
	if top_normal.normalized().dot(Vector3.UP) < tuning.minimum_top_up_dot:
		geometry_rejection_count += 1
		return
	_result.has_top = true
	_result.top_point = top_hit["position"]
	_result.top_normal = top_normal.normalized()
	_result.obstacle_height = _result.top_point.y - foot_height
	_result.mantle_target = _result.top_point + Vector3.UP * (_body_half_height + tuning.destination_clearance)
	_result.hang_target = Vector3(
		_result.wall_point.x,
		_result.top_point.y - tuning.ledge_hang_body_drop,
		_result.wall_point.z
	) + _result.wall_normal * (_body_radius + tuning.ledge_wall_clearance)
	_result.destination_clear = is_position_clear(body, _result.mantle_target, tuning)

	var landing_sample := _result.wall_point + direction * tuning.vault_forward_distance
	_result.landing_ray_start = Vector3(
		landing_sample.x,
		_result.top_point.y + _body_half_height + tuning.vault_apex_clearance + tuning.vault_landing_probe_above,
		landing_sample.z
	)
	_result.landing_ray_end = Vector3(landing_sample.x, foot_height - tuning.vault_landing_probe_depth, landing_sample.z)
	var landing_hit := _cast_ray(body, _result.landing_ray_start, _result.landing_ray_end, tuning)
	if landing_hit.is_empty():
		return
	var landing_normal: Vector3 = landing_hit["normal"]
	if landing_normal.normalized().dot(Vector3.UP) < tuning.minimum_top_up_dot:
		return
	var landing_position: Vector3 = landing_hit["position"]
	_result.vault_target = landing_position + Vector3.UP * (_body_half_height + tuning.destination_clearance)
	_result.vault_landing_found = is_position_clear(body, _result.vault_target, tuning)


func _cast_ray(
	body: CharacterBody3D,
	start: Vector3,
	end: Vector3,
	tuning: TraversalTuning
) -> Dictionary:
	if _query_count >= tuning.maximum_queries_per_frame:
		return {}
	_query_count += 1
	ray_query_count += 1
	_ray_parameters.from = start
	_ray_parameters.to = end
	return body.get_world_3d().direct_space_state.intersect_ray(_ray_parameters)


func _configure_for_body(body: CharacterBody3D, tuning: TraversalTuning) -> void:
	if _excluded_body_id == body.get_instance_id():
		_ray_parameters.collision_mask = tuning.collision_mask
		return
	_excluded_body_id = body.get_instance_id()
	_ray_parameters.exclude = [body.get_rid()]
	_ray_parameters.collision_mask = tuning.collision_mask
	_ray_parameters.collide_with_areas = false
	_ray_parameters.collide_with_bodies = true
	_ray_parameters.hit_from_inside = false
	var collision_shape := body.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape:
		_shape_parameters.shape = collision_shape.shape
		_shape_parameters.exclude = [body.get_rid()]
		_shape_parameters.collision_mask = tuning.collision_mask
		_shape_parameters.collide_with_areas = false
		_shape_parameters.collide_with_bodies = true
		if collision_shape.shape is CapsuleShape3D:
			var capsule := collision_shape.shape as CapsuleShape3D
			_body_half_height = capsule.height * 0.5
			_body_radius = capsule.radius


func _is_usable_surface(collider: CollisionObject3D) -> bool:
	if collider == null or not collider is StaticBody3D:
		return false
	if collider.is_in_group(&"traversal_invalid") or collider.get_meta(&"traversal_invalid", false):
		return false
	return collider.is_in_group(&"traversal_surface") or collider.get_meta(&"traversal_surface", false)


func _finish_probe() -> void:
	last_queries_per_probe = _query_count
	peak_queries_per_probe = maxi(peak_queries_per_probe, _query_count)
