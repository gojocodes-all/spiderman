class_name MovementTuning
extends Resource

@export_group("Speed Bands")
@export_range(0.1, 8.0, 0.1) var walk_speed := 3.4
@export_range(1.0, 14.0, 0.1) var jog_speed := 7.2
@export_range(2.0, 20.0, 0.1) var sprint_speed := 11.8
@export_range(2.0, 24.0, 0.1) var maximum_air_speed := 13.2
@export_range(0.1, 0.9, 0.01) var walk_input_threshold := 0.42
@export_range(0.1, 1.0, 0.01) var sprint_input_threshold := 0.72
@export_range(0.0, 0.3, 0.005) var input_deadzone := 0.08

@export_group("Ground Response")
@export_range(1.0, 120.0, 1.0) var ground_acceleration := 38.0
@export_range(1.0, 140.0, 1.0) var ground_deceleration := 48.0
@export_range(1.0, 180.0, 1.0) var direction_change_acceleration := 68.0
@export_range(0.0, 1.0, 0.01) var direction_change_dot_threshold := 0.1
@export_range(0.0, 4.0, 0.05) var grounded_stick_velocity := 0.65

@export_group("Jump and Gravity")
@export_range(1.0, 30.0, 0.1) var jump_velocity := 10.8
@export_range(1.0, 60.0, 0.1) var gravity := 26.0
@export_range(0.2, 2.0, 0.05) var rising_gravity_multiplier := 1.0
@export_range(0.5, 3.0, 0.05) var falling_gravity_multiplier := 1.35
@export_range(5.0, 100.0, 1.0) var terminal_fall_speed := 55.0
@export_range(0.0, 0.3, 0.005) var coyote_time := 0.11
@export_range(0.0, 0.3, 0.005) var jump_buffer_time := 0.12
@export_range(0.0, 0.3, 0.005) var jumping_state_time := 0.08

@export_group("Air Response")
@export_range(0.0, 50.0, 0.5) var air_acceleration := 12.0
@export_range(0.0, 1.0, 0.01) var air_control := 0.72
@export_range(0.0, 10.0, 0.1) var air_drag := 0.5

@export_group("Facing")
@export_range(30.0, 1440.0, 10.0) var grounded_rotation_speed_degrees := 720.0
@export_range(30.0, 1440.0, 10.0) var air_rotation_speed_degrees := 540.0

@export_group("Floor and Steps")
@export_range(1.0, 80.0, 1.0) var maximum_slope_angle_degrees := 48.0
@export_range(0.0, 1.0, 0.01) var floor_snap_length := 0.48
@export_range(0.001, 0.1, 0.001) var collision_safe_margin := 0.02
@export_range(1, 16, 1) var maximum_slide_collisions := 8
@export_range(0.0, 0.8, 0.01) var maximum_step_height := 0.38
@export_range(0.0, 1.0, 0.01) var step_down_probe := 0.52
@export_range(0.001, 0.1, 0.001) var minimum_step_forward_motion := 0.002
@export_range(0.0, 0.1, 0.001) var step_clearance := 0.025
@export_range(0.1, 1.5, 0.01) var step_surface_probe_forward := 0.55
@export_range(0.5, 3.0, 0.05) var step_floor_probe_depth := 1.4

@export_group("Landing")
@export_range(0.0, 30.0, 0.1) var soft_landing_speed := 6.5
@export_range(0.0, 50.0, 0.1) var hard_landing_speed := 14.0
@export_range(0.0, 1.0, 0.01) var soft_landing_recovery := 0.12
@export_range(0.0, 2.0, 0.01) var hard_landing_recovery := 0.36
@export_range(0.0, 1.0, 0.01) var soft_landing_control_scale := 0.72
@export_range(0.0, 1.0, 0.01) var hard_landing_control_scale := 0.25
@export_range(0.0, 1.0, 0.01) var minimum_air_time_for_landing := 0.08

@export_group("Temporary Traversal Probe")
@export_range(0.0, 40.0, 0.1) var burst_impulse := 13.0
@export_range(0.0, 1.0, 0.01) var burst_upward_ratio := 0.32
@export_range(0.0, 5.0, 0.05) var burst_cooldown_seconds := 0.7


func ground_target_speed(input_strength: float, sprint_requested: bool, walk_requested: bool) -> float:
	var strength := clampf(input_strength, 0.0, 1.0)
	if strength <= input_deadzone:
		return 0.0
	if sprint_requested and not walk_requested and strength >= sprint_input_threshold:
		return sprint_speed * strength
	if walk_requested:
		return walk_speed * strength
	if strength <= walk_input_threshold:
		return walk_speed * strength / walk_input_threshold
	var jog_alpha := (strength - walk_input_threshold) / (1.0 - walk_input_threshold)
	return lerpf(walk_speed, jog_speed, jog_alpha)


func rotation_speed_radians(grounded: bool) -> float:
	var degrees_per_second := grounded_rotation_speed_degrees if grounded else air_rotation_speed_degrees
	return deg_to_rad(degrees_per_second)
