class_name TraversalProbeResult
extends RefCounted

var has_obstacle := false
var has_wall := false
var wall_is_usable := false
var wall_point := Vector3.ZERO
var wall_normal := Vector3.ZERO
var wall_direction := Vector3.ZERO
var wall_distance := 0.0
var wall_angle_degrees := 0.0
var wall_collider: CollisionObject3D
var surface_name := StringName()

var has_top := false
var top_point := Vector3.ZERO
var top_normal := Vector3.UP
var obstacle_height := 0.0
var destination_clear := false
var mantle_target := Vector3.ZERO
var vault_target := Vector3.ZERO
var vault_landing_found := false
var hang_target := Vector3.ZERO

var lower_ray_start := Vector3.ZERO
var lower_ray_end := Vector3.ZERO
var upper_ray_start := Vector3.ZERO
var upper_ray_end := Vector3.ZERO
var top_ray_start := Vector3.ZERO
var top_ray_end := Vector3.ZERO
var landing_ray_start := Vector3.ZERO
var landing_ray_end := Vector3.ZERO


func reset() -> void:
	has_obstacle = false
	has_wall = false
	wall_is_usable = false
	wall_point = Vector3.ZERO
	wall_normal = Vector3.ZERO
	wall_direction = Vector3.ZERO
	wall_distance = 0.0
	wall_angle_degrees = 0.0
	wall_collider = null
	surface_name = StringName()
	has_top = false
	top_point = Vector3.ZERO
	top_normal = Vector3.UP
	obstacle_height = 0.0
	destination_clear = false
	mantle_target = Vector3.ZERO
	vault_target = Vector3.ZERO
	vault_landing_found = false
	hang_target = Vector3.ZERO
	lower_ray_start = Vector3.ZERO
	lower_ray_end = Vector3.ZERO
	upper_ray_start = Vector3.ZERO
	upper_ray_end = Vector3.ZERO
	top_ray_start = Vector3.ZERO
	top_ray_end = Vector3.ZERO
	landing_ray_start = Vector3.ZERO
	landing_ray_end = Vector3.ZERO
