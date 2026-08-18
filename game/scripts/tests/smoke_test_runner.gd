extends Node


func _ready() -> void:
	if DisplayServer.get_name() == "headless" or OS.get_environment("AV_RUN_SMOKE_TESTS") == "1":
		call_deferred("_run_suite")


func _run_suite() -> void:
	await _wait_physics_frames(12)
	var player := get_tree().get_first_node_in_group(&"player") as CharacterBody3D
	if player == null:
		_fail("player group is missing")
		return
	var avatar := player as RelayAvatar

	var building_count := get_tree().get_nodes_in_group(&"city_building").size()
	if building_count < 12:
		_fail("expected at least 12 blockout buildings, found %d" % building_count)
		return

	if get_tree().get_first_node_in_group(&"quality_manager") == null:
		_fail("quality manager is missing")
		return

	await _wait_physics_frames(24)
	var start := player.global_position
	avatar.input_router.set_touch_move(Vector2(0.0, -1.0))
	await _wait_physics_frames(24)
	avatar.input_router.set_touch_move(Vector2.ZERO)
	var horizontal_distance := Vector2(start.x, start.z).distance_to(
		Vector2(player.global_position.x, player.global_position.z)
	)
	if horizontal_distance < 0.6:
		_fail("locomotion probe moved only %.3f m" % horizontal_distance)
		return

	for _attempt in range(30):
		if player.is_on_floor():
			break
		await get_tree().physics_frame
	if not player.is_on_floor():
		_fail("player did not regain grounded state before jump probe")
		return

	avatar.input_router.request_touch_jump()
	await _wait_physics_frames(1)
	var jump_velocity := player.velocity.y
	if jump_velocity <= 0.0:
		_fail("jump probe did not produce upward velocity")
		return

	avatar.input_router.request_touch_burst()
	await _wait_physics_frames(1)
	var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
	if horizontal_speed < 8.0:
		_fail("burst probe speed was only %.3f m/s" % horizontal_speed)
		return

	Input.action_release(&"move_forward")
	Input.action_release(&"jump")
	Input.action_release(&"burst")
	print(
		"[SMOKE] PASS buildings=%d distance=%.2f jump_v=%.2f burst_speed=%.2f" % [
			building_count,
			horizontal_distance,
			jump_velocity,
			horizontal_speed,
		]
	)
	get_tree().quit(0)


func _wait_physics_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await get_tree().physics_frame


func _fail(message: String) -> void:
	Input.action_release(&"move_forward")
	Input.action_release(&"jump")
	Input.action_release(&"burst")
	push_error("[SMOKE] FAIL %s" % message)
	get_tree().quit(1)
