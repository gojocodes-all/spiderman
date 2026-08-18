extends Node

var _player: RelayAvatar
var _lab: MovementTraversalLab
var _overlay: TouchInputOverlay
var _failed := false
var _suite_started_usec := 0
var _distance_30_hz := 0.0
var _distance_60_hz := 0.0


func _ready() -> void:
	if DisplayServer.get_name() == "headless" or OS.get_environment("AV_RUN_SMOKE_TESTS") == "1":
		call_deferred("_run_suite")


func _run_suite() -> void:
	_suite_started_usec = Time.get_ticks_usec()
	await _wait_physics_frames(10)
	_player = get_tree().get_first_node_in_group(&"player") as RelayAvatar
	_lab = get_parent().get_node("TraversalLab") as MovementTraversalLab
	_overlay = get_parent().get_node("TouchInputOverlay") as TouchInputOverlay
	if not _check(_player != null, "player group is missing"):
		return
	if not _check(_lab != null, "movement laboratory is missing"):
		return
	if not _check(_overlay != null, "touch overlay is missing"):
		return
	var requested_filter := OS.get_environment("AV_M1_TEST_FILTER")
	if requested_filter == "geometry":
		await _test_steps_stairs_and_slopes()
		if not _failed:
			print("[M1 TEST] PASS filtered=geometry")
			get_tree().quit(0)
		return
	if requested_filter == "camera":
		await _test_camera_limits_and_recenter()
		if not _failed:
			print("[M1 TEST] PASS filtered=camera")
			get_tree().quit(0)
		return

	_test_architecture_and_data()
	if _failed:
		return
	await _test_speed_bands_and_response()
	if _failed:
		return
	await _test_camera_relative_movement()
	if _failed:
		return
	await _test_fixed_tick_consistency()
	if _failed:
		return
	await _test_direction_changes()
	if _failed:
		return
	await _test_jump_air_control_and_spam()
	if _failed:
		return
	await _test_landings_and_runoff()
	if _failed:
		return
	await _test_steps_stairs_and_slopes()
	if _failed:
		return
	await _test_walls_narrow_platform_and_camera_collision()
	if _failed:
		return
	_test_aspect_ratio_layouts()
	if _failed:
		return
	_test_simultaneous_touch_channels()
	if _failed:
		return
	await _test_camera_limits_and_recenter()
	if _failed:
		return
	await _test_milestone_zero_regression()
	if _failed:
		return

	_release_all_inputs()
	Engine.physics_ticks_per_second = 60
	var elapsed_ms := float(Time.get_ticks_usec() - _suite_started_usec) / 1000.0
	print("[M1 TEST] PASS suite_ms=%.1f distance_30=%.3f distance_60=%.3f features=%d" % [
		elapsed_ms,
		_distance_30_hz,
		_distance_60_hz,
		_lab.feature_count(),
	])
	print("[SMOKE] PASS milestone=1 movement_lab=true camera_collision=true multitouch=true")
	get_tree().quit(0)


func _test_architecture_and_data() -> void:
	var tuning := _player.movement_component.tuning
	_check(_lab.feature_count() >= 55, "laboratory has too few deliberate collision features")
	_check(get_tree().get_nodes_in_group(&"lab_stairs").size() >= 20, "stair coverage is missing")
	_check(get_tree().get_nodes_in_group(&"lab_ramp").size() >= 5, "ramp and roof-access coverage is missing")
	_check(get_tree().get_nodes_in_group(&"lab_alley").size() >= 4, "tight alley coverage is missing")
	_check(get_tree().get_nodes_in_group(&"lab_rooftop").size() >= 5, "rooftop/gap coverage is missing")
	_check(get_tree().get_nodes_in_group(&"quality_manager").size() == 1, "quality manager is missing or duplicated")
	_check(_player.movement_state_machine != null, "movement state machine is missing")
	_check(_player.movement_component.step_up_solver != null, "step-up solver is missing")
	_check(tuning.walk_speed < tuning.jog_speed and tuning.jog_speed < tuning.sprint_speed, "movement speed bands are unordered")
	_check(tuning.soft_landing_speed < tuning.hard_landing_speed, "landing thresholds are unordered")
	_check(tuning.maximum_step_height < 0.5, "step solver exceeds the small-obstacle contract")
	_check(_action_has_event_class(&"move_forward", &"InputEventJoypadMotion"), "controller left-stick movement mapping is missing")
	_check(_action_has_event_class(&"look_right", &"InputEventJoypadMotion"), "controller right-stick camera mapping is missing")
	_check(_action_has_event_class(&"jump", &"InputEventJoypadButton"), "controller jump mapping is missing")
	var first_snapshot := _player.input_router.consume_snapshot()
	var second_snapshot := _player.input_router.consume_snapshot()
	_check(first_snapshot.get_instance_id() == second_snapshot.get_instance_id(), "input snapshots allocate every sample")
	if not _failed:
		_pass("architecture_data", "states=9 reusable_input_snapshot=true features=%d" % _lab.feature_count())


func _test_speed_bands_and_response() -> void:
	Engine.physics_ticks_per_second = 60
	await _reset_to_marker(&"FlatRunStart")
	_player.input_router.set_touch_move(Vector2(0.0, -0.30))
	await _wait_physics_frames(50)
	var walk_speed := _horizontal_speed()
	_check(walk_speed > 1.8 and walk_speed < 3.5, "walk band speed %.3f is outside tuning" % walk_speed)
	_check(
		_player.movement_state_machine.current_state == MovementStateMachine.MovementState.WALKING,
		"analog walk did not enter walking state"
	)

	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(40)
	var jog_speed := _horizontal_speed()
	_check(absf(jog_speed - _player.movement_component.tuning.jog_speed) < 0.35, "jog speed %.3f did not reach target" % jog_speed)
	_check(
		_player.movement_state_machine.current_state == MovementStateMachine.MovementState.JOGGING,
		"full input without sprint did not enter jogging state"
	)

	_player.input_router.set_touch_sprint(true)
	await _wait_physics_frames(30)
	var sprint_speed := _horizontal_speed()
	_check(absf(sprint_speed - _player.movement_component.tuning.sprint_speed) < 0.4, "sprint speed %.3f did not reach target" % sprint_speed)
	_check(
		_player.movement_state_machine.current_state == MovementStateMachine.MovementState.SPRINTING,
		"sprint hold did not enter sprinting state"
	)

	_player.input_router.set_touch_move(Vector2.ZERO)
	_player.input_router.set_touch_sprint(false)
	await _wait_physics_frames(1)
	var first_deceleration_speed := _horizontal_speed()
	_check(first_deceleration_speed > 0.0 and first_deceleration_speed < sprint_speed, "deceleration snapped or failed on its first frame")
	await _wait_physics_frames(20)
	_check(_horizontal_speed() < 0.15, "ground deceleration did not settle to idle")
	_check(
		_player.movement_state_machine.current_state == MovementStateMachine.MovementState.IDLE,
		"settled player did not enter idle state"
	)
	if not _failed:
		_pass("speed_bands", "walk=%.2f jog=%.2f sprint=%.2f" % [walk_speed, jog_speed, sprint_speed])


func _test_camera_relative_movement() -> void:
	await _reset_to_marker(&"FlatRunStart")
	_player.camera_rig.snap_to_target(Vector3.RIGHT)
	await _wait_process_frames(2)
	var start := _player.global_position
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(45)
	_player.input_router.set_touch_move(Vector2.ZERO)
	var displacement := _player.global_position - start
	_check(displacement.x > 3.0, "camera-relative forward input did not move toward camera-right world direction")
	_check(absf(displacement.z) < displacement.x * 0.35, "camera-relative motion leaked excessively into world Z")
	if not _failed:
		_pass("camera_relative", "delta=(%.2f, %.2f)" % [displacement.x, displacement.z])


func _test_fixed_tick_consistency() -> void:
	_distance_30_hz = await _measure_sprint_distance(30, 1.5)
	_distance_60_hz = await _measure_sprint_distance(60, 1.5)
	var difference := absf(_distance_30_hz - _distance_60_hz)
	_check(difference < 0.65, "30/60 Hz sprint distance diverged by %.3f m" % difference)
	_check(_distance_30_hz > 12.0 and _distance_60_hz > 12.0, "fixed-tick sprint probes under-travelled")
	if not _failed:
		_pass("fixed_tick_30_60", "distance30=%.3f distance60=%.3f delta=%.3f" % [_distance_30_hz, _distance_60_hz, difference])


func _test_direction_changes() -> void:
	Engine.physics_ticks_per_second = 60
	await _reset_to_marker(&"DirectionChangeStart")
	var start := _player.global_position
	var maximum_speed := 0.0
	for cycle in 24:
		_player.input_router.set_touch_move(Vector2(-1.0 if cycle % 2 == 0 else 1.0, 0.0))
		await _wait_physics_frames(4)
		maximum_speed = maxf(maximum_speed, _horizontal_speed())
	_player.input_router.set_touch_move(Vector2.ZERO)
	await _wait_physics_frames(20)
	var drift := Vector2(start.x, start.z).distance_to(Vector2(_player.global_position.x, _player.global_position.z))
	_check(is_finite(_player.global_position.x) and is_finite(_player.global_position.z), "rapid direction changes produced a non-finite transform")
	_check(maximum_speed <= _player.movement_component.tuning.jog_speed + 0.4, "direction reversal exceeded the jog cap")
	_check(drift < 3.0, "symmetric rapid direction changes drifted %.3f m" % drift)
	if not _failed:
		_pass("rapid_direction_changes", "max_speed=%.2f drift=%.2f" % [maximum_speed, drift])


func _test_jump_air_control_and_spam() -> void:
	await _reset_to_marker(&"FlatRunStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	_player.input_router.set_touch_sprint(true)
	await _wait_physics_frames(45)
	_player.input_router.request_touch_jump()
	await _wait_physics_frames(2)
	var sprint_jump_horizontal := _horizontal_speed()
	var sprint_jump_vertical := _player.velocity.y
	_check(sprint_jump_horizontal > 10.5, "sprint jump lost horizontal momentum")
	_check(sprint_jump_vertical > 8.5, "sprint jump did not produce upward velocity")
	_check(_player.movement_state_machine.has_visited(MovementStateMachine.MovementState.JUMPING), "jumping state was not visited")

	var before_air_steer := _player.global_position.x
	_player.input_router.set_touch_move(Vector2(1.0, 0.0))
	await _wait_physics_frames(24)
	var air_steer_distance := _player.global_position.x - before_air_steer
	_check(air_steer_distance > 0.25, "air steering displacement was only %.3f m" % air_steer_distance)

	var saw_falling := false
	for frame in 190:
		if frame % 7 == 0:
			_player.input_router.request_touch_jump()
		await _wait_physics_frames(1)
		if _player.movement_state_machine.current_state == MovementStateMachine.MovementState.FALLING:
			saw_falling = true
	_player.input_router.set_touch_move(Vector2.ZERO)
	_player.input_router.set_touch_sprint(false)
	await _wait_until_grounded(180)
	_check(_player.movement_state_machine.jump_count >= 2, "jump spam did not produce repeatable buffered jumps")
	_check(saw_falling, "falling state was not observed during repeated jumps")
	if not _failed:
		_pass("jump_air_control_spam", "jump_v=%.2f sprint=%.2f air_dx=%.2f jumps=%d" % [
			sprint_jump_vertical,
			sprint_jump_horizontal,
			air_steer_distance,
			_player.movement_state_machine.jump_count,
		])


func _test_landings_and_runoff() -> void:
	await _reset_to_marker(&"SoftLandingDrop", 0)
	var soft_landed := await _wait_for_new_landing(180)
	var soft_impact := _player.movement_state_machine.last_landing_impact_speed
	_check(soft_landed, "soft landing probe never reached the floor")
	_check(
		_player.movement_state_machine.last_landing_state == MovementStateMachine.MovementState.SOFT_LANDING,
		"medium-height drop was not classified as a soft landing (impact %.2f)" % soft_impact
	)

	await _reset_to_marker(&"HardLandingDrop", 0)
	var hard_landed := await _wait_for_new_landing(240)
	var hard_impact := _player.movement_state_machine.last_landing_impact_speed
	_check(hard_landed, "hard landing probe never reached the floor")
	_check(
		_player.movement_state_machine.last_landing_state == MovementStateMachine.MovementState.HARD_LANDING,
		"high drop was not classified as a hard landing (impact %.2f)" % hard_impact
	)
	_check(_player.movement_state_machine.landing_recovery_remaining > 0.0, "hard landing recovery was not applied")

	await _reset_to_marker(&"RoofEdgeStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	_player.input_router.set_touch_sprint(true)
	var saw_airborne := false
	var saw_fall_state := false
	for _frame in 180:
		await _wait_physics_frames(1)
		if not _player.is_on_floor():
			saw_airborne = true
		if _player.movement_state_machine.current_state == MovementStateMachine.MovementState.FALLING:
			saw_fall_state = true
		if saw_airborne and _player.is_on_floor():
			break
	_player.input_router.set_touch_move(Vector2.ZERO)
	_player.input_router.set_touch_sprint(false)
	_check(saw_airborne and saw_fall_state, "running off a roof did not produce airborne/falling states")
	_check(_player.is_on_floor(), "run-off probe did not land within its deterministic window")
	if not _failed:
		_pass("landing_and_edges", "soft=%.2f hard=%.2f runoff=true" % [soft_impact, hard_impact])


func _test_steps_stairs_and_slopes() -> void:
	await _reset_to_marker(&"StepStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(150)
	_player.input_router.set_touch_move(Vector2.ZERO)
	var step_solver := _player.movement_component.step_up_solver
	_check(_player.global_position.z < 19.0, "small-step lane blocked before the supported step heights at z=%.3f y=%.3f calls=%d no_wall=%d small=%d attempts=%d success=%d clearance=%d height=%d surface=%d" % [
		_player.global_position.z,
		_player.global_position.y,
		step_solver.solver_call_count,
		step_solver.no_wall_rejection_count,
		step_solver.small_motion_rejection_count,
		step_solver.probe_attempt_count,
		step_solver.successful_step_count,
		step_solver.raised_clearance_rejection_count,
		step_solver.height_rejection_count,
		step_solver.surface_rejection_count,
	])
	_check(_player.global_position.z > 14.7, "over-height step was traversed instead of blocking at z=%.3f" % _player.global_position.z)

	await _reset_to_marker(&"ShortStairsStart")
	_player.movement_component.step_up_solver.reset_diagnostics()
	var stairs_max_y := await _drive_forward_capture_height(100)
	var solver := _player.movement_component.step_up_solver
	_check(stairs_max_y > 1.9, "short stairs were not climbed (max y %.3f z %.3f attempts=%d success=%d clearance=%d height=%d surface=%d)" % [
		stairs_max_y,
		_player.global_position.z,
		solver.probe_attempt_count,
		solver.successful_step_count,
		solver.raised_clearance_rejection_count,
		solver.height_rejection_count,
		solver.surface_rejection_count,
	])

	await _reset_to_marker(&"LongStairsStart")
	var long_stairs_max_y := await _drive_forward_capture_height(190)
	_check(long_stairs_max_y > 3.8, "long stairs were not climbed (max y %.3f)" % long_stairs_max_y)

	await _reset_to_marker(&"GradualRampStart")
	var gradual_max_y := await _drive_forward_capture_height(170)
	_check(gradual_max_y > 4.6, "gradual ramp ascent stalled (max y %.3f)" % gradual_max_y)

	await _reset_to_marker(&"SteepRampStart")
	var steep_max_y := await _drive_forward_capture_height(150)
	_check(steep_max_y > 5.5, "walkable steep ramp ascent stalled (max y %.3f)" % steep_max_y)

	await _reset_to_marker(&"SteepRampStart")
	_player.reset_motion_at(Vector3(35.0, 1.05, 24.0), Vector3.FORWARD)
	await _wait_physics_frames(6)
	var rejected_max_y := await _drive_forward_capture_height(100)
	_check(rejected_max_y < 2.5, "55-degree rejected slope was treated as walkable (max y %.3f)" % rejected_max_y)
	if not _failed:
		_pass("steps_stairs_slopes", "short=%.2f long=%.2f ramp18=%.2f ramp38=%.2f ramp55=%.2f" % [
			stairs_max_y,
			long_stairs_max_y,
			gradual_max_y,
			steep_max_y,
			rejected_max_y,
		])


func _test_walls_narrow_platform_and_camera_collision() -> void:
	await _reset_to_marker(&"WallCollisionStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(100)
	_player.input_router.set_touch_move(Vector2.ZERO)
	_check(_player.global_position.z > -3.3, "player penetrated the wall collision plane")
	_check(absf(_player.global_position.x - 35.0) < 0.35, "wall collision introduced excessive lateral drift")

	await _reset_to_marker(&"NarrowPlatformStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(24)
	_player.input_router.set_touch_move(Vector2.ZERO)
	_check(_player.is_on_floor(), "straight narrow-platform run lost grounded state")
	_check(absf(_player.global_position.x - 29.0) < 0.18, "narrow-platform run accumulated lateral drift")

	await _reset_to_marker(&"CameraCollisionStart")
	await _wait_process_frames(10)
	var obstructed_ratio := _player.camera_rig.get_obstruction_ratio()
	_check(obstructed_ratio > 0.1 and obstructed_ratio < 0.72, "camera obstruction ratio %.3f did not compress in the collision bay" % obstructed_ratio)
	await _reset_to_marker(&"FlatRunStart")
	await _wait_process_frames(10)
	var clear_ratio := _player.camera_rig.get_obstruction_ratio()
	_check(clear_ratio > 0.92, "camera spring arm did not recover after leaving obstruction")
	if not _failed:
		_pass("walls_platform_camera_collision", "obstructed=%.2f clear=%.2f" % [obstructed_ratio, clear_ratio])


func _test_aspect_ratio_layouts() -> void:
	var view_sizes: Array[Vector2] = [
		Vector2(1280.0, 720.0),
		Vector2(2400.0, 1080.0),
		Vector2(2340.0, 1080.0),
		Vector2(1920.0, 1200.0),
		Vector2(1024.0, 768.0),
	]
	for viewport_size in view_sizes:
		var layout := _overlay.debug_layout_snapshot(viewport_size)
		var move_center: Vector2 = layout["move_center"]
		var move_radius: float = layout["move_radius"]
		var move_bounds := Rect2(move_center - Vector2.ONE * move_radius, Vector2.ONE * move_radius * 2.0)
		for key in [&"jump", &"sprint", &"burst"]:
			var button_rect: Rect2 = layout[key]
			_check(button_rect.position.x >= 0.0 and button_rect.position.y >= 0.0, "%s button escaped the %s layout" % [key, viewport_size])
			_check(button_rect.end.x <= viewport_size.x and button_rect.end.y <= viewport_size.y, "%s button exceeded the %s layout" % [key, viewport_size])
			_check(not move_bounds.intersects(button_rect), "%s button overlaps the movement joystick at %s" % [key, viewport_size])
	if not _failed:
		_pass("aspect_ratios", "16:9 20:9 19.5:9 16:10 4:3")


func _test_simultaneous_touch_channels() -> void:
	var before_angles := _player.camera_rig.get_orbit_angles()
	var move_press := InputEventScreenTouch.new()
	move_press.index = 11
	move_press.position = Vector2(180.0, 540.0)
	move_press.pressed = true
	_overlay._input(move_press)
	var look_press := InputEventScreenTouch.new()
	look_press.index = 22
	look_press.position = Vector2(850.0, 320.0)
	look_press.pressed = true
	_overlay._input(look_press)

	var move_drag := InputEventScreenDrag.new()
	move_drag.index = 11
	move_drag.position = Vector2(180.0, 450.0)
	_overlay._input(move_drag)
	var look_drag := InputEventScreenDrag.new()
	look_drag.index = 22
	look_drag.position = Vector2(940.0, 275.0)
	_overlay._input(look_drag)
	_player.input_router.request_touch_jump()
	_overlay._set_sprint(true)
	var snapshot := _player.input_router.consume_snapshot()
	var touch_ids := _overlay.debug_touch_ids()
	var after_angles := _player.camera_rig.get_orbit_angles()
	_check(touch_ids == Vector2i(11, 22), "move and look touches did not retain independent IDs")
	_check(snapshot.move.length() > 0.7, "movement touch was lost while look touch was active")
	_check(snapshot.jump_pressed, "jump one-shot was lost while move and look touches were active")
	_check(snapshot.sprint_held, "sprint hold was lost while move and look touches were active")
	_check(absf(after_angles.x - before_angles.x) > 0.05, "look drag did not rotate the camera during movement touch")

	var move_release := InputEventScreenTouch.new()
	move_release.index = 11
	move_release.position = move_drag.position
	move_release.pressed = false
	_overlay._input(move_release)
	var look_release := InputEventScreenTouch.new()
	look_release.index = 22
	look_release.position = look_drag.position
	look_release.pressed = false
	_overlay._input(look_release)
	_overlay._set_sprint(false)
	_check(_overlay.debug_touch_ids() == Vector2i(-1, -1), "touch channels did not release independently")
	if not _failed:
		_pass("simultaneous_touch", "move+look+jump retained")


func _test_camera_limits_and_recenter() -> void:
	await _reset_to_marker(&"FlatRunStart")
	var mouse_before := _player.camera_rig.get_orbit_angles()
	var mouse_press := InputEventMouseButton.new()
	mouse_press.button_index = MOUSE_BUTTON_RIGHT
	mouse_press.pressed = true
	_player.camera_rig._unhandled_input(mouse_press)
	var mouse_motion := InputEventMouseMotion.new()
	mouse_motion.relative = Vector2(48.0, -20.0)
	_player.camera_rig._unhandled_input(mouse_motion)
	var mouse_release := InputEventMouseButton.new()
	mouse_release.button_index = MOUSE_BUTTON_RIGHT
	mouse_release.pressed = false
	_player.camera_rig._unhandled_input(mouse_release)
	var mouse_after := _player.camera_rig.get_orbit_angles()
	_check(absf(angle_difference(mouse_after.x, mouse_before.x)) > 0.05, "right-mouse camera orbit did not respond")

	_player.camera_rig.apply_look_delta(Vector2(0.0, 100000.0))
	var minimum_pitch := _player.camera_rig.get_orbit_angles().y
	_player.camera_rig.apply_look_delta(Vector2(0.0, -200000.0))
	var maximum_pitch := _player.camera_rig.get_orbit_angles().y
	var camera_tuning := _player.camera_rig.tuning
	_check(minimum_pitch >= deg_to_rad(camera_tuning.minimum_pitch_degrees) - 0.001, "camera pitch exceeded its lower limit")
	_check(maximum_pitch <= deg_to_rad(camera_tuning.maximum_pitch_degrees) + 0.001, "camera pitch exceeded its upper limit")

	_player.set_physics_process(false)
	_player.camera_rig.set_motion_context(Vector3.ZERO, Vector3.ZERO, 0.0)
	await _wait_process_frames(12)
	var slow_arm := _player.camera_rig.spring_arm.spring_length
	var slow_fov := _player.camera_rig.camera.fov
	_player.camera_rig.set_motion_context(Vector3.FORWARD * 12.0, Vector3.FORWARD, 1.0)
	await _wait_process_frames(30)
	var fast_arm := _player.camera_rig.spring_arm.spring_length
	var fast_fov := _player.camera_rig.camera.fov
	_check(fast_arm > slow_arm + 0.5 and fast_fov > slow_fov + 3.0, "speed-sensitive camera arm/FOV response did not engage")

	_player.camera_rig.snap_to_target(Vector3.RIGHT)
	var yaw_before := _player.camera_rig.get_orbit_angles().x
	_player.camera_rig.set_motion_context(Vector3.FORWARD * 7.0, Vector3.FORWARD, 1.0)
	_player.camera_rig.request_recenter()
	await _wait_process_frames(45)
	_player.set_physics_process(true)
	var yaw_after := _player.camera_rig.get_orbit_angles().x
	_check(absf(angle_difference(yaw_after, 0.0)) < absf(angle_difference(yaw_before, 0.0)), "camera recenter did not move toward travel direction (before %.2f after %.2f)" % [yaw_before, yaw_after])
	if not _failed:
		_pass("camera_limits_recenter", "pitch=[%.1f, %.1f] arm=%.2f>%.2f fov=%.1f>%.1f" % [
			rad_to_deg(minimum_pitch),
			rad_to_deg(maximum_pitch),
			fast_arm,
			slow_arm,
			fast_fov,
			slow_fov,
		])


func _test_milestone_zero_regression() -> void:
	await _reset_to_marker(&"FlatRunStart")
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(24)
	var locomotion_distance := Vector2(0.0, 34.0).distance_to(Vector2(_player.global_position.x, _player.global_position.z))
	_player.input_router.request_touch_jump()
	await _wait_physics_frames(2)
	var jump_velocity := _player.velocity.y
	_player.input_router.request_touch_burst()
	await _wait_physics_frames(2)
	var burst_speed := _horizontal_speed()
	_check(locomotion_distance > 1.5, "Milestone 0 movement regression")
	_check(jump_velocity > 8.0, "Milestone 0 jump regression")
	_check(burst_speed > 12.0, "Milestone 0 burst regression")
	if not _failed:
		_pass("milestone_0_regression", "distance=%.2f jump=%.2f burst=%.2f" % [locomotion_distance, jump_velocity, burst_speed])


func _measure_sprint_distance(ticks_per_second: int, duration_seconds: float) -> float:
	Engine.physics_ticks_per_second = ticks_per_second
	await _reset_to_marker(&"FlatRunStart", 6)
	var start := _player.global_position
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	_player.input_router.set_touch_sprint(true)
	await _wait_physics_frames(roundi(duration_seconds * ticks_per_second))
	_player.input_router.set_touch_move(Vector2.ZERO)
	_player.input_router.set_touch_sprint(false)
	return Vector2(start.x, start.z).distance_to(Vector2(_player.global_position.x, _player.global_position.z))


func _drive_forward_capture_height(frame_count: int) -> float:
	var maximum_y := _player.global_position.y
	_player.input_router.set_touch_move(Vector2(0.0, -1.0))
	for _frame in frame_count:
		await _wait_physics_frames(1)
		maximum_y = maxf(maximum_y, _player.global_position.y)
	_player.input_router.set_touch_move(Vector2.ZERO)
	return maximum_y


func _reset_to_marker(marker_name: StringName, settle_frames: int = 6) -> void:
	_release_all_inputs()
	var marker_node := _lab.marker(marker_name)
	if marker_node == null:
		_fail("missing laboratory marker %s" % marker_name)
		return
	var facing: Vector3 = marker_node.get_meta(&"forward", Vector3.FORWARD)
	_player.reset_motion_at(marker_node.global_position, facing)
	if settle_frames > 0:
		await _wait_physics_frames(settle_frames)


func _wait_for_new_landing(maximum_frames: int) -> bool:
	var initial_count := _player.movement_state_machine.landing_count
	for _frame in maximum_frames:
		await _wait_physics_frames(1)
		if _player.movement_state_machine.landing_count > initial_count:
			return true
	return false


func _wait_until_grounded(maximum_frames: int) -> bool:
	for _frame in maximum_frames:
		await _wait_physics_frames(1)
		if _player.is_on_floor():
			return true
	return false


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in frame_count:
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame in frame_count:
		await get_tree().process_frame


func _horizontal_speed() -> float:
	return Vector2(_player.velocity.x, _player.velocity.z).length()


func _action_has_event_class(action: StringName, event_class: StringName) -> bool:
	for event in InputMap.action_get_events(action):
		if event.get_class() == event_class:
			return true
	return false


func _release_all_inputs() -> void:
	if _player:
		_player.input_router.clear_touch_input()
	for action in [&"move_forward", &"move_back", &"move_left", &"move_right", &"jump", &"walk", &"sprint", &"burst", &"camera_recenter"]:
		Input.action_release(action)


func _check(condition: bool, message: String) -> bool:
	if condition:
		return true
	_fail(message)
	return false


func _pass(test_name: String, details: String) -> void:
	print("[M1 TEST] PASS %s %s" % [test_name, details])


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	_release_all_inputs()
	Engine.physics_ticks_per_second = 60
	push_error("[M1 TEST] FAIL %s" % message)
	get_tree().quit(1)
