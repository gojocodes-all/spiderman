class_name TraversalTuning
extends Resource

@export_group("Surface Detection")
@export_flags_3d_physics var collision_mask := 1
@export_range(0.4, 2.5, 0.05) var forward_probe_distance := 1.85
@export_range(-0.8, 0.8, 0.05) var lower_probe_height := -0.48
@export_range(-0.4, 1.2, 0.05) var upper_probe_height := 0.34
@export_range(0.05, 1.5, 0.05) var minimum_wall_probe_separation := 0.62
@export_range(0.0, 0.6, 0.01) var maximum_wall_up_dot := 0.22
@export_range(0.0, 1.0, 0.01) var matching_wall_normal_dot := 0.86
@export_range(0.0, 1.0, 0.01) var minimum_top_up_dot := 0.72
@export_range(0.05, 1.0, 0.01) var top_probe_inset := 0.42
@export_range(0.0, 1.0, 0.01) var top_probe_above_body_margin := 0.3
@export_range(0.0, 1.0, 0.01) var top_probe_below_feet := 0.2
@export_range(0.2, 1.5, 0.05) var ledge_forward_clearance := 0.58
@export_range(0.0, 0.25, 0.005) var destination_clearance := 0.045
@export_range(0.0, 1.0, 0.01) var destination_shape_margin_scale := 0.25
@export_range(0.0, 1.5, 0.05) var vault_landing_probe_above := 0.4
@export_range(0.5, 4.0, 0.05) var vault_landing_probe_depth := 1.8
@export_range(0.0, 1.0, 0.01) var active_wall_probe_extra_distance := 0.35
@export_range(1, 16, 1) var maximum_queries_per_frame := 8

@export_group("Horizontal Wall Run")
@export_range(1.0, 20.0, 0.1) var wall_run_minimum_entry_speed := 5.4
@export_range(3.0, 30.0, 0.1) var wall_run_maximum_entry_speed := 16.0
@export_range(0.1, 4.0, 0.05) var wall_run_maximum_duration := 1.45
@export_range(0.0, 1.0, 0.01) var wall_run_gravity_multiplier := 0.22
@export_range(0.0, 40.0, 0.5) var wall_run_adhesion_force := 16.0
@export_range(0.0, 10.0, 0.1) var wall_run_speed_loss := 1.25
@export_range(0.5, 15.0, 0.1) var wall_run_minimum_exit_speed := 3.8
@export_range(0.0, 1.0, 0.01) var wall_run_minimum_approach_dot := 0.12
@export_range(0.0, 1.0, 0.01) var wall_run_maximum_direct_approach_dot := 0.78
@export_range(0.0, 1.0, 0.01) var wall_run_minimum_tangent_input := 0.28
@export_range(0.0, 1.0, 0.01) var wall_run_minimum_tangent_speed_ratio := 0.72
@export_range(1.0, 90.0, 1.0) var wall_run_maximum_normal_change_degrees := 38.0
@export_range(0.0, 1.0, 0.01) var wall_run_exit_away_dot := 0.48
@export_range(0.0, 1.0, 0.01) var wall_run_reentry_cooldown := 0.24
@export_range(0.0, 10.0, 0.1) var wall_run_minimum_adhesion_speed := 0.8
@export_range(0.0, 10.0, 0.1) var wall_run_maximum_adhesion_speed := 2.5

@export_group("Vertical Wall Traversal")
@export_range(1.0, 20.0, 0.1) var vertical_minimum_entry_speed := 4.2
@export_range(0.0, 1.0, 0.01) var vertical_minimum_direct_approach_dot := 0.72
@export_range(0.0, 25.0, 0.1) var vertical_initial_upward_speed := 8.8
@export_range(0.1, 3.0, 0.05) var vertical_maximum_duration := 0.88
@export_range(0.0, 40.0, 0.5) var vertical_gravity := 11.0
@export_range(0.5, 10.0, 0.1) var vertical_distance_limit := 4.25
@export_range(0.0, 2.0, 0.05) var vertical_run_to_climb_time := 0.38
@export_range(0.0, 40.0, 0.5) var vertical_adhesion_force := 18.0
@export_range(0.0, 10.0, 0.1) var vertical_minimum_adhesion_speed := 0.9
@export_range(0.0, 10.0, 0.1) var vertical_maximum_adhesion_speed := 2.6
@export_range(0.0, 10.0, 0.1) var vertical_lateral_speed := 1.4
@export_range(-10.0, 5.0, 0.1) var vertical_exit_speed := -1.4

@export_group("Wall Jump")
@export_range(1.0, 25.0, 0.1) var wall_jump_outward_speed := 8.4
@export_range(1.0, 25.0, 0.1) var wall_jump_upward_speed := 8.9
@export_range(0.0, 1.5, 0.01) var wall_jump_tangent_preservation := 0.76
@export_range(0.0, 8.0, 0.1) var wall_jump_input_influence := 2.2
@export_range(1.0, 60.0, 0.5) var wall_jump_gravity := 26.0
@export_range(0.0, 1.0, 0.01) var wall_jump_motion_lock := 0.14
@export_range(0.0, 1.0, 0.01) var wall_jump_reattach_cooldown := 0.26
@export_range(1, 8, 1) var maximum_wall_jump_chain := 3
@export_range(0.0, 1.0, 0.01) var exhausted_chain_upward_scale := 0.32

@export_group("Vault")
@export_range(0.1, 1.5, 0.05) var vault_minimum_height := 0.42
@export_range(0.4, 2.0, 0.05) var vault_maximum_height := 1.05
@export_range(0.5, 15.0, 0.1) var vault_minimum_speed := 4.0
@export_range(0.5, 3.0, 0.05) var vault_forward_distance := 1.75
@export_range(0.1, 1.2, 0.01) var vault_duration := 0.36
@export_range(0.0, 1.5, 0.05) var vault_apex_clearance := 0.42
@export_range(0.05, 0.45, 0.01) var vault_lift_fraction := 0.28
@export_range(0.5, 0.9, 0.01) var vault_cross_fraction := 0.72
@export_range(0.0, 1.25, 0.01) var vault_momentum_preservation := 0.94

@export_group("Mantle")
@export_range(0.3, 2.0, 0.05) var mantle_minimum_height := 0.78
@export_range(0.8, 4.0, 0.05) var mantle_maximum_height := 2.35
@export_range(0.5, 3.0, 0.05) var mantle_detection_range := 1.35
@export_range(0.05, 1.5, 0.05) var mantle_stand_inset := 0.58
@export_range(0.1, 1.5, 0.01) var mantle_duration := 0.52
@export_range(0.0, 1.0, 0.01) var mantle_lift_fraction := 0.56
@export_range(0.0, 1.5, 0.05) var mantle_lift_clearance := 0.14
@export_range(0.0, 15.0, 0.1) var mantle_minimum_approach_speed := 1.8
@export_range(0.0, 1.25, 0.01) var mantle_momentum_preservation := 0.78

@export_group("Ledge Grab")
@export_range(0.4, 2.5, 0.05) var ledge_grab_range := 1.3
@export_range(0.1, 2.0, 0.05) var ledge_vertical_tolerance := 0.9
@export_range(-15.0, 5.0, 0.1) var ledge_maximum_rising_speed := 0.35
@export_range(0.1, 1.5, 0.01) var ledge_hang_body_drop := 0.72
@export_range(0.0, 1.0, 0.01) var ledge_hand_height_fraction := 0.72
@export_range(0.0, 0.5, 0.01) var ledge_wall_clearance := 0.12
@export_range(0.05, 0.5, 0.01) var ledge_snap_duration := 0.14
@export_range(0.1, 1.5, 0.01) var ledge_climb_duration := 0.56
@export_range(0.0, 1.0, 0.01) var ledge_drop_away_dot := 0.52
@export_range(0.0, 1.0, 0.01) var ledge_drop_hold_time := 0.22
@export_range(0.0, 10.0, 0.1) var ledge_drop_speed := 2.5
@export_range(0.0, 10.0, 0.1) var ledge_drop_outward_speed := 1.4
@export_range(0.0, 5.0, 0.1) var ledge_shimmy_speed := 1.5
@export_range(0.0, 1.0, 0.01) var ledge_shimmy_input_deadzone := 0.2
@export_range(0.02, 0.5, 0.01) var ledge_validation_interval := 0.1
@export_range(0.0, 1.0, 0.01) var ledge_regrab_cooldown := 0.32

@export_group("Recovery and Presentation")
@export_range(0.0, 1.0, 0.01) var traversal_recovery_time := 0.16
@export_range(0.0, 30.0, 0.5) var wall_run_visual_lean_degrees := 12.0
@export_range(0.0, 30.0, 0.5) var vertical_visual_lean_degrees := 8.0
@export_range(1.0, 40.0, 0.5) var visual_pose_sharpness := 14.0
@export_range(0.5, 1.0, 0.01) var scripted_collision_completion_threshold := 0.96
@export_range(0.0, 1.0, 0.01) var scripted_abort_momentum_preservation := 0.5
