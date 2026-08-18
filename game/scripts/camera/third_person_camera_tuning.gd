class_name ThirdPersonCameraTuning
extends Resource

@export_group("Orbit")
@export_range(0.0001, 0.02, 0.0001) var touch_mouse_sensitivity := 0.0032
@export_range(10.0, 360.0, 1.0) var controller_degrees_per_second := 150.0
@export_range(-89.0, 0.0, 1.0) var minimum_pitch_degrees := -55.0
@export_range(0.0, 89.0, 1.0) var maximum_pitch_degrees := 24.0
@export_range(-60.0, 20.0, 1.0) var default_pitch_degrees := -13.0

@export_group("Follow")
@export var target_offset := Vector3(0.0, 1.05, 0.0)
@export_range(1.0, 40.0, 0.5) var follow_sharpness := 18.0
@export_range(0.0, 3.0, 0.05) var maximum_look_ahead := 0.9
@export_range(1.0, 30.0, 0.5) var look_ahead_sharpness := 9.0

@export_group("Speed Response")
@export_range(1.0, 12.0, 0.1) var base_arm_length := 6.2
@export_range(0.0, 5.0, 0.1) var maximum_speed_arm_extension := 1.15
@export_range(30.0, 120.0, 1.0) var base_field_of_view := 70.0
@export_range(0.0, 30.0, 0.5) var maximum_speed_fov_addition := 8.0
@export_range(1.0, 40.0, 0.5) var speed_response_sharpness := 8.0
@export_range(1.0, 40.0, 0.5) var speed_for_full_response := 12.0

@export_group("Traversal Readability")
@export_range(0.0, 3.0, 0.05) var traversal_direction_look_ahead := 0.55
@export_range(0.0, 2.0, 0.05) var traversal_vertical_offset := 0.48
@export_range(0.0, 2.0, 0.05) var traversal_wall_side_offset := 0.24
@export_range(0.0, 20.0, 0.5) var traversal_field_of_view_addition := 3.5
@export_range(0.0, 3.0, 0.05) var traversal_arm_extension := 0.45
@export_range(1.0, 30.0, 0.5) var traversal_response_sharpness := 9.0

@export_group("Recentering")
@export_range(0.0, 10.0, 0.1) var automatic_recenter_delay := 1.35
@export_range(1.0, 20.0, 0.5) var automatic_recenter_sharpness := 4.8
@export_range(1.0, 30.0, 0.5) var requested_recenter_sharpness := 12.0
@export_range(0.0, 1.0, 0.01) var recenter_move_threshold := 0.3

@export_group("Collision")
@export_range(0.0, 1.0, 0.01) var collision_margin := 0.18
@export_range(0.05, 1.0, 0.01) var collision_probe_radius := 0.24
