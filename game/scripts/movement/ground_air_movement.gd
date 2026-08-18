class_name GroundAirMovement
extends Node

@export_group("Ground")
@export var max_ground_speed := 11.0
@export var ground_acceleration := 48.0
@export var ground_deceleration := 58.0
@export var jump_velocity := 10.5

@export_group("Air")
@export var max_air_speed := 13.5
@export var air_acceleration := 15.0
@export var gravity_multiplier := 1.0

@export_group("Traversal Probe")
@export var burst_impulse := 13.0
@export var burst_upward_ratio := 0.32
@export var burst_cooldown_seconds := 0.7

var _burst_cooldown_remaining := 0.0
var _gravity := 22.0


func _ready() -> void:
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 22.0))


func simulate(
	body: CharacterBody3D,
	wish_direction: Vector3,
	jump_pressed: bool,
	burst_pressed: bool,
	delta: float
) -> void:
	_burst_cooldown_remaining = maxf(0.0, _burst_cooldown_remaining - delta)

	var grounded := body.is_on_floor()
	var horizontal_velocity := Vector3(body.velocity.x, 0.0, body.velocity.z)
	var target_speed := max_ground_speed if grounded else max_air_speed
	var target_velocity := wish_direction * target_speed
	var acceleration := air_acceleration
	if grounded:
		acceleration = ground_acceleration if wish_direction.length_squared() > 0.001 else ground_deceleration
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, acceleration * delta)
	body.velocity.x = horizontal_velocity.x
	body.velocity.z = horizontal_velocity.z

	if grounded:
		if jump_pressed:
			body.velocity.y = jump_velocity
		elif body.velocity.y < 0.0:
			body.velocity.y = -0.5
	else:
		body.velocity.y -= _gravity * gravity_multiplier * delta

	if burst_pressed and _burst_cooldown_remaining <= 0.0:
		var launch_direction := wish_direction
		if launch_direction.length_squared() < 0.001:
			launch_direction = -body.global_transform.basis.z
		launch_direction.y = burst_upward_ratio
		body.velocity += launch_direction.normalized() * burst_impulse
		_burst_cooldown_remaining = burst_cooldown_seconds

	body.move_and_slide()
