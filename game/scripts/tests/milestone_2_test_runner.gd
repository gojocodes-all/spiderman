extends Node

var _player: RelayAvatar
var _lab: MovementTraversalLab
var _overlay: TouchInputOverlay
var _failed := false
var _suite_started_usec := 0


func _ready() -> void:
	if OS.get_environment("AV_TEST_SUITE") == "m2":
		call_deferred("_run_suite")


func _run_suite() -> void:
	_suite_started_usec = Time.get_ticks_usec()
	await _wait_physics_frames(10)
	_player = get_tree().get_first_node_in_group(&"player") as RelayAvatar
	_lab = get_parent().get_node("TraversalLab") as MovementTraversalLab
	_overlay = get_parent().get_node("TouchInputOverlay") as TouchInputOverlay
	if not _check(_player != null, "player group is missing"):
		return
	if not _check(_lab != null, "parkour laboratory is missing"):
		return
	if not _check(_overlay != null, "touch overlay is missing"):
		return

	var requested_filter := OS.get_environment("AV_M2_TEST_FILTER")
	if requested_filter == "detection":
		_test_architecture_and_state_contract()
		await _test_surface_detection_and_rejection()
	elif requested_filter == "wall":
		await _test_horizontal_wall_run_and_jump()
		await _test_vertical_wall_limit()
		await _test_wall_edge_cases_and_recovery()
	elif requested_filter == "parkour":
		await _test_vault_mantle_and_ledge()
		await _test_ledge_drop_and_jump_away()
	elif requested_filter == "camera":
		await _test_camera_debug_and_multitouch()
	else:
		_test_architecture_and_state_contract()
		if _failed:
			return
		await _test_surface_detection_and_rejection()
		if _failed:
			return
		await _test_horizontal_wall_run_and_jump()
		if _failed:
			return
		await _test_vertical_wall_limit()
		if _failed:
			return
		await _test_wall_edge_cases_and_recovery()
		if _failed:
			return
		await _test_vault_mantle_and_ledge()
		if _failed:
			return
		await _test_ledge_drop_and_jump_away()
		if _failed:
			return
		await _test_camera_debug_and_multitouch()
	if _failed:
		return

	_release_all_inputs()
	Engine.physics_ticks_per_second = 60
	var elapsed_ms := float(Time.get_ticks_usec() - _suite_started_usec) / 1000.0
	print("[M2 TEST] PASS suite_ms=%.1f features=%d markers=%d peak_probe_queries=%d" % [
		elapsed_ms,
		_lab.feature_count(),
		get_tree().get_nodes_in_group(&"lab_marker").size(),
		_player.traversal_component.detector.peak_queries_per_probe,
	])
	print("[SMOKE] PASS milestone=2 parkour=true wall_traversal=true m1_preserved=true")
	get_tree().quit(0)


func _test_architecture_and_state_contract() -> void:
	var traversal := _player.traversal_component
	var tuning := traversal.tuning
	_check(_player.movement_component != null, "Milestone 1 movement component was removed")
	_check(_player.movement_state_machine != null, "Milestone 1 movement state machine was removed")
	_check(traversal.state_machine != null, "traversal state machine is missing")
	_check(traversal.detector != null, "traversal detector is missing")
	_check(TraversalStateMachine.STATE_NAMES.size() == 10, "traversal state contract does not contain ten exclusive states")
	_check(get_tree().get_nodes_in_group(&"lab_parkour").size() >= 24, "parkour laboratory coverage is too small")
	_check(get_tree().get_nodes_in_group(&"lab_wall_run").size() >= 5, "wall-run laboratory surfaces are missing")
	_check(get_tree().get_nodes_in_group(&"lab_vault").size() >= 4, "vault laboratory surfaces are missing")
	_check(get_tree().get_nodes_in_group(&"lab_mantle").size() >= 4, "mantle laboratory surfaces are missing")
	_check(get_tree().get_nodes_in_group(&"lab_ledge").size() >= 3, "ledge laboratory surfaces are missing")
	_check(tuning.wall_run_minimum_exit_speed < tuning.wall_run_minimum_entry_speed, "wall-run speed thresholds are unordered")
	_check(tuning.vault_minimum_height < tuning.vault_maximum_height, "vault height thresholds are unordered")
	_check(tuning.mantle_minimum_height < tuning.mantle_maximum_height, "mantle height thresholds are unordered")
	_check(tuning.vertical_distance_limit < 6.0, "vertical traversal limit is effectively unbounded")
	_check(tuning.maximum_wall_jump_chain <= 3, "wall-jump anti-height-gain budget is too permissive")
	var debug_visualizer := traversal.get_node("DebugVisualizer") as TraversalDebugVisualizer
	_check(debug_visualizer != null and not debug_visualizer.is_debug_enabled(), "traversal debug visualization is enabled by default")
	var rejected_before := traversal.state_machine.rejected_transition_count
	var accepted := traversal.state_machine.transition(TraversalStateMachine.TraversalState.WALL_JUMP, &"illegal_test")
	_check(not accepted, "state machine accepted contradictory idle-to-wall-jump transition")
	_check(traversal.state_machine.rejected_transition_count == rejected_before + 1, "rejected transition was not diagnosed")
	traversal.state_machine.reset()
	if not _failed:
		_pass("architecture_state", "states=10 parkour_features=%d debug_default=false" % get_tree().get_nodes_in_group(&"lab_parkour").size())


func _test_surface_detection_and_rejection() -> void:
	_player.set_physics_process(false)
	var marker := _lab.marker(&"ParkourWallRunStart")
	_player.reset_motion_at(marker.global_position, marker.get_meta(&"forward"))
	await _wait_physics_frames(1)
	var direction: Vector3 = marker.get_meta(&"forward")
	var valid_probe := _player.traversal_component.detector.probe(
		_player,
		direction,
		_player.traversal_component.tuning,
		2.0,
		true
	)
	_check(valid_probe.has_wall, "valid wall-run surface did not produce a two-height wall result")
	_check(valid_probe.wall_is_usable, "explicit traversal wall was rejected")
	_check(absf(valid_probe.wall_normal.dot(Vector3.UP)) <= 0.05, "valid wall normal was not near vertical")

	marker = _lab.marker(&"ParkourInvalidWallStart")
	_player.reset_motion_at(marker.global_position, marker.get_meta(&"forward"))
	await _wait_physics_frames(1)
	var invalid_probe := _player.traversal_component.detector.probe(
		_player,
		marker.get_meta(&"forward"),
		_player.traversal_component.tuning,
		2.8,
		true
	)
	_check(invalid_probe.has_obstacle, "explicit invalid wall was not detected as collision geometry")
	_check(not invalid_probe.wall_is_usable, "explicit invalid wall was accepted for traversal")

	marker = _lab.marker(&"ParkourTinyObjectStart")
	_player.reset_motion_at(marker.global_position, marker.get_meta(&"forward"))
	await _wait_physics_frames(1)
	var tiny_probe := _player.traversal_component.detector.probe(
		_player,
		marker.get_meta(&"forward"),
		_player.traversal_component.tuning,
		2.8,
		true
	)
	_check(not tiny_probe.has_wall, "tiny object passed the separated wall-probe requirement")

	marker = _lab.marker(&"ParkourBlockedMantleStart")
	_player.reset_motion_at(marker.global_position, marker.get_meta(&"forward"))
	await _wait_physics_frames(1)
	var blocked_probe := _player.traversal_component.detector.probe(
		_player,
		marker.get_meta(&"forward"),
		_player.traversal_component.tuning,
		1.8,
		true
	)
	_check(not blocked_probe.destination_clear, "ceiling-blocked mantle destination was accepted")
	_check(_player.traversal_component.detector.peak_queries_per_probe <= _player.traversal_component.tuning.maximum_queries_per_frame, "detector exceeded its per-probe ray budget")
	_player.set_physics_process(true)
	if not _failed:
		_pass("surface_detection", "valid=true invalid_rejected=true tiny_rejected=true blocked_rejected=true queries<=%d" % _player.traversal_component.tuning.maximum_queries_per_frame)


func _test_horizontal_wall_run_and_jump() -> void:
	var direction := await _prepare_airborne(
		&"ParkourWallRunStart",
		9.2,
		1.4
	)
	var entered := await _wait_for_visited_state(TraversalStateMachine.TraversalState.WALL_RUN, 24)
	_check(entered, "angled fast wall approach did not enter horizontal wall run")
	var entry_speed := _horizontal_speed()
	var entry_position := _player.global_position
	await _wait_physics_frames(16)
	var wall_distance := Vector2(entry_position.x, entry_position.z).distance_to(Vector2(_player.global_position.x, _player.global_position.z))
	_check(wall_distance > 1.2, "horizontal wall run failed to advance along the wall")
	_check(_horizontal_speed() >= _player.traversal_component.tuning.wall_run_minimum_exit_speed, "wall run discarded useful momentum")
	var wall_normal := _player.traversal_component.current_wall_normal
	_player.input_router.request_touch_jump()
	await _wait_physics_frames(2)
	_check(_player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_JUMP), "wall jump state was not visited")
	_check(Vector3(_player.velocity.x, 0.0, _player.velocity.z).dot(wall_normal) > 3.0, "wall jump did not launch away from the wall")
	_check(_player.velocity.y > 4.0, "wall jump did not preserve a useful upward launch")
	await _wait_physics_frames(28)
	_check(_player.traversal_state_machine.current_state != TraversalStateMachine.TraversalState.WALL_RUN, "wall adhesion persisted after wall jump")
	_check(_player.traversal_component.wall_jump_chain_count <= _player.traversal_component.tuning.maximum_wall_jump_chain, "wall jump chain budget was exceeded")
	_release_all_inputs()
	if not _failed:
		_pass("horizontal_wall_run_jump", "entry=%.2f travel=%.2f away=%.2f direction=(%.2f,%.2f)" % [entry_speed, wall_distance, Vector3(_player.velocity.x, 0.0, _player.velocity.z).dot(wall_normal), direction.x, direction.z])


func _test_vertical_wall_limit() -> void:
	await _prepare_airborne(&"ParkourVerticalLimitStart", 6.6, 3.8)
	var start_height := _player.global_position.y
	var entered := await _wait_for_any_visited_state([
		TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN,
		TraversalStateMachine.TraversalState.WALL_CLIMB,
	], 24)
	_check(entered, "direct wall approach did not enter vertical traversal")
	var maximum_height := _player.global_position.y
	for _frame in 120:
		await _wait_physics_frames(1)
		maximum_height = maxf(maximum_height, _player.global_position.y)
		if not _player.traversal_state_machine.owns_character_motion() and _player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_CLIMB):
			break
	var rise := maximum_height - start_height
	_check(rise > 1.2, "vertical traversal produced too little upward travel")
	_check(rise <= _player.traversal_component.tuning.vertical_distance_limit + 0.8, "vertical traversal exceeded its distance limit")
	_check(_player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_CLIMB), "vertical wall run never decayed into wall climb")
	_check(_player.traversal_state_machine.current_state not in [TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, TraversalStateMachine.TraversalState.WALL_CLIMB], "vertical traversal remained locked after its limit")
	_release_all_inputs()
	if not _failed:
		_pass("vertical_limit", "rise=%.2f limit=%.2f climb_visited=true" % [rise, _player.traversal_component.tuning.vertical_distance_limit])


func _test_wall_edge_cases_and_recovery() -> void:
	await _prepare_airborne(&"ParkourWallRunStart", 3.0, 1.0)
	await _wait_physics_frames(22)
	_check(not _player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_RUN), "extremely slow entry incorrectly started wall run")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourInvalidWallStart", 9.0, 1.0)
	await _wait_physics_frames(26)
	_check(_player.traversal_state_machine.current_state == TraversalStateMachine.TraversalState.IDLE, "explicit invalid wall started traversal")
	_check(_player.traversal_component.last_action == &"none", "invalid wall recorded a traversal action")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourWallRunStart", 24.0, 1.0)
	var fast_entered := await _wait_for_visited_state(TraversalStateMachine.TraversalState.WALL_RUN, 20)
	_check(fast_entered, "high-speed valid approach failed to enter wall run")
	await _wait_physics_frames(2)
	_check(_horizontal_speed() <= _player.traversal_component.tuning.wall_run_maximum_entry_speed + 1.0, "wall run failed to clamp extreme entry speed")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourWallRunEndProbe", 9.0, 1.0)
	var end_entered := await _wait_for_visited_state(TraversalStateMachine.TraversalState.WALL_RUN, 24)
	_check(end_entered, "near-end wall approach failed to enter wall run")
	for _frame in 100:
		await _wait_physics_frames(1)
		if _player.traversal_component.last_exit_reason == &"wall_ended":
			break
	_check(_player.traversal_component.last_exit_reason in [&"wall_ended", &"wall_run_duration", &"wall_angle_changed"], "wall end did not produce a clean airborne exit")
	_check(_player.traversal_state_machine.current_state not in [TraversalStateMachine.TraversalState.WALL_RUN, TraversalStateMachine.TraversalState.VERTICAL_WALL_RUN, TraversalStateMachine.TraversalState.WALL_CLIMB], "wall-end recovery remained stuck in traversal")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourWallRunStart", 9.0, 1.0)
	_player.traversal_component.wall_jump_chain_count = _player.traversal_component.tuning.maximum_wall_jump_chain
	await _wait_physics_frames(24)
	_check(not _player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_RUN), "exhausted wall-jump chain reattached before grounding")
	_release_all_inputs()
	if not _failed:
		_pass("wall_edge_cases", "slow_rejected invalid_rejected high_clamped end_exit_clean chain_budget_enforced")


func _test_vault_mantle_and_ledge() -> void:
	await _reset_to_marker(&"ParkourVaultStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	_player.input_router.set_touch_sprint(true)
	var vault_started := await _wait_for_visited_state(TraversalStateMachine.TraversalState.VAULT, 90)
	_check(vault_started, "sprint toward low clear obstacle did not start vault")
	var vault_completed := await _wait_for_successful_action(90)
	_check(vault_completed, "vault did not complete cleanly state=%s exit=%s aborted=%d pos=(%.2f,%.2f,%.2f)" % [
		_player.traversal_component.state_name(),
		_player.traversal_component.last_exit_reason,
		_player.traversal_component.aborted_action_count,
		_player.global_position.x,
		_player.global_position.y,
		_player.global_position.z,
	])
	_check(_player.global_position.z < -5.4, "vault did not reach the far side of the obstacle")
	var post_vault_speed := _horizontal_speed()
	_check(post_vault_speed > 3.5, "vault discarded forward momentum")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourMantleStart", 5.4, 2.8)
	var mantle_started := await _wait_for_visited_state(TraversalStateMachine.TraversalState.MANTLE, 40)
	var mantle_probe := _player.traversal_component.current_probe()
	_check(mantle_started, "jump toward reachable medium wall did not start mantle state=%s ledge_visited=%s last=%s exit=%s obstacle=%s usable=%s top=%s height=%.2f clear=%s vy=%.2f pos=(%.2f,%.2f,%.2f)" % [
		_player.traversal_component.state_name(),
		_player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.LEDGE_GRAB),
		_player.traversal_component.last_action,
		_player.traversal_component.last_exit_reason,
		mantle_probe.has_obstacle,
		mantle_probe.wall_is_usable,
		mantle_probe.has_top,
		mantle_probe.obstacle_height,
		mantle_probe.destination_clear,
		_player.velocity.y,
		_player.global_position.x,
		_player.global_position.y,
		_player.global_position.z,
	])
	var mantle_completed := await _wait_for_successful_action(100)
	_check(mantle_completed, "mantle did not complete cleanly")
	_check(_player.global_position.y > 2.45, "mantle did not place the player above the obstacle")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourWideLedgeGrab", 2.2, -2.4)
	var grabbed := await _wait_for_visited_state(TraversalStateMachine.TraversalState.LEDGE_GRAB, 36)
	_check(grabbed, "falling near a valid wide ledge did not grab")
	await _wait_physics_frames(12)
	_check(_player.velocity.length() < 0.1, "ledge hang did not settle velocity")
	_player.input_router.request_touch_jump()
	var climbed := await _wait_for_visited_state(TraversalStateMachine.TraversalState.LEDGE_CLIMB, 20)
	_check(climbed, "JUMP from ledge hang did not start ledge climb")
	var ledge_completed := await _wait_for_successful_action(110)
	_check(ledge_completed, "ledge climb did not complete")
	_check(_player.global_position.y > 5.55, "ledge climb did not reach the tower top")
	_release_all_inputs()
	if not _failed:
		_pass("vault_mantle_ledge", "vault_speed=%.2f mantle_y=%.2f ledge_y=%.2f momentum=true" % [post_vault_speed, 2.45, _player.global_position.y])


func _test_ledge_drop_and_jump_away() -> void:
	await _prepare_airborne(&"ParkourWideLedgeGrab", 2.2, -2.4)
	var grabbed_for_drop := await _wait_for_visited_state(TraversalStateMachine.TraversalState.LEDGE_GRAB, 36)
	_check(grabbed_for_drop, "ledge drop test could not establish a hang")
	await _wait_physics_frames(12)
	_player.input_router.set_touch_move(Vector2(0.0, 1.0))
	await _wait_physics_frames(18)
	_check(_player.traversal_component.last_exit_reason == &"ledge_drop", "holding away from ledge did not request a contextual drop")
	_check(_player.traversal_state_machine.current_state != TraversalStateMachine.TraversalState.LEDGE_GRAB, "ledge drop remained stuck in hang")
	_release_all_inputs()

	await _prepare_airborne(&"ParkourWideLedgeGrab", 2.2, -2.4)
	var grabbed_for_jump := await _wait_for_visited_state(TraversalStateMachine.TraversalState.LEDGE_GRAB, 36)
	_check(grabbed_for_jump, "ledge jump-away test could not establish a hang")
	await _wait_physics_frames(12)
	var wall_normal := _player.traversal_component.current_wall_normal
	_player.input_router.set_touch_move(Vector2(0.0, 1.0))
	_player.input_router.request_touch_jump()
	await _wait_physics_frames(2)
	_check(_player.traversal_state_machine.has_visited(TraversalStateMachine.TraversalState.WALL_JUMP), "away input plus JUMP did not launch from ledge")
	_check(Vector3(_player.velocity.x, 0.0, _player.velocity.z).dot(wall_normal) > 3.0, "ledge jump-away did not move away from the surface")
	_release_all_inputs()
	if not _failed:
		_pass("ledge_drop_jump", "hold_away=drop away+jump=wall_jump no_lock=true")


func _test_camera_debug_and_multitouch() -> void:
	await _reset_to_marker(&"FlatRunStart")
	_player.set_physics_process(false)
	_player.camera_rig.set_motion_context(Vector3.ZERO, Vector3.ZERO, 0.0)
	_player.camera_rig.set_traversal_context(&"idle", Vector3.ZERO, Vector3.ZERO)
	await _wait_process_frames(45)
	var base_fov := _player.camera_rig.camera.fov
	var yaw_before := _player.camera_rig.get_orbit_angles().x
	_player.camera_rig.set_traversal_context(&"wall_run", Vector3.FORWARD, Vector3.RIGHT)
	await _wait_process_frames(45)
	var traversal_fov := _player.camera_rig.camera.fov
	var yaw_after := _player.camera_rig.get_orbit_angles().x
	_check(traversal_fov > base_fov + 1.2, "parkour camera readability response did not raise FOV (%.2f <= %.2f)" % [traversal_fov, base_fov])
	_check(absf(angle_difference(yaw_before, yaw_after)) < 0.08, "parkour camera forced a strong yaw rotation")
	var debug_visualizer := _player.traversal_component.get_node("DebugVisualizer") as TraversalDebugVisualizer
	debug_visualizer.set_debug_enabled(true)
	await _wait_process_frames(2)
	_check(debug_visualizer.is_debug_enabled(), "developer traversal visualization could not be enabled")
	debug_visualizer.set_debug_enabled(false)
	_check(not debug_visualizer.is_debug_enabled(), "developer traversal visualization did not disable")
	_player.set_physics_process(true)

	var move_press := InputEventScreenTouch.new()
	move_press.index = 31
	move_press.position = Vector2(180.0, 540.0)
	move_press.pressed = true
	_overlay._input(move_press)
	var look_press := InputEventScreenTouch.new()
	look_press.index = 32
	look_press.position = Vector2(880.0, 320.0)
	look_press.pressed = true
	_overlay._input(look_press)
	var move_drag := InputEventScreenDrag.new()
	move_drag.index = 31
	move_drag.position = Vector2(180.0, 445.0)
	_overlay._input(move_drag)
	var look_drag := InputEventScreenDrag.new()
	look_drag.index = 32
	look_drag.position = Vector2(940.0, 270.0)
	_overlay._input(look_drag)
	_player.input_router.request_touch_jump()
	var snapshot := _player.input_router.consume_snapshot()
	_check(_overlay.debug_touch_ids() == Vector2i(31, 32), "parkour multitouch lost independent move/look IDs")
	_check(snapshot.move.length() > 0.7 and snapshot.jump_pressed, "move/look/JUMP intent was not retained together")
	_release_touch(31, move_drag.position)
	_release_touch(32, look_drag.position)
	if not _failed:
		_pass("camera_debug_multitouch", "fov=%.1f>%.1f forced_yaw=false debug_toggle=true move+look+jump=true" % [traversal_fov, base_fov])


func _prepare_airborne(marker_name: StringName, horizontal_speed: float, vertical_speed: float) -> Vector3:
	_release_all_inputs()
	var marker := _lab.marker(marker_name)
	if marker == null:
		_fail("missing laboratory marker %s" % marker_name)
		return Vector3.FORWARD
	var direction: Vector3 = marker.get_meta(&"forward", Vector3.FORWARD)
	_player.reset_motion_at(marker.global_position, direction)
	await _wait_physics_frames(2)
	_player.velocity = Vector3(direction.x, 0.0, direction.z).normalized() * horizontal_speed + Vector3.UP * vertical_speed
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	_player.input_router.set_touch_sprint(true)
	return direction


func _reset_to_marker(marker_name: StringName, settle_frames: int = 6) -> void:
	_release_all_inputs()
	_player.set_physics_process(true)
	var marker := _lab.marker(marker_name)
	if marker == null:
		_fail("missing laboratory marker %s" % marker_name)
		return
	var facing: Vector3 = marker.get_meta(&"forward", Vector3.FORWARD)
	_player.reset_motion_at(marker.global_position, facing)
	await _wait_physics_frames(settle_frames)


func _wait_for_visited_state(state: TraversalStateMachine.TraversalState, maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await _wait_physics_frames(1)
		if _player.traversal_state_machine.has_visited(state):
			return true
	return false


func _wait_for_any_visited_state(states: Array, maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await _wait_physics_frames(1)
		for state in states:
			if _player.traversal_state_machine.has_visited(state):
				return true
	return false


func _wait_for_successful_action(maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await _wait_physics_frames(1)
		if _player.traversal_component.successful_action_count > 0:
			return true
	return false


func _release_touch(index: int, position_value: Vector2) -> void:
	var release := InputEventScreenTouch.new()
	release.index = index
	release.position = position_value
	release.pressed = false
	_overlay._input(release)


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in frame_count:
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame in frame_count:
		await get_tree().process_frame


func _horizontal_speed() -> float:
	return Vector2(_player.velocity.x, _player.velocity.z).length()


func _release_all_inputs() -> void:
	if _player:
		_player.input_router.clear_touch_input()
	for action in [&"move_forward", &"move_back", &"move_left", &"move_right", &"jump", &"walk", &"sprint", &"burst", &"camera_recenter", &"traversal_debug"]:
		Input.action_release(action)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _pass(test_name: String, details: String) -> void:
	print("[M2 TEST] PASS %s %s" % [test_name, details])


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	_release_all_inputs()
	_player.set_physics_process(true) if _player else null
	Engine.physics_ticks_per_second = 60
	push_error("[M2 TEST] FAIL %s" % message)
	get_tree().quit(1)
