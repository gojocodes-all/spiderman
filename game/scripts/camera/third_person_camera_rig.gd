class_name ThirdPersonCameraRig
extends Node3D

@export var look_sensitivity := 0.0032
@export var min_pitch_degrees := -52.0
@export var max_pitch_degrees := 18.0

@onready var camera: Camera3D = $SpringArm3D/Camera3D

var _yaw := 0.0
var _pitch := deg_to_rad(-12.0)
var _mouse_looking := false


func _ready() -> void:
	_yaw = rotation.y
	_pitch = rotation.x


func world_direction_from_input(move_input: Vector2) -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	return (right * move_input.x + forward * -move_input.y).limit_length(1.0)


func apply_look_delta(pixel_delta: Vector2) -> void:
	_yaw -= pixel_delta.x * look_sensitivity
	_pitch -= pixel_delta.y * look_sensitivity
	_pitch = clampf(_pitch, deg_to_rad(min_pitch_degrees), deg_to_rad(max_pitch_degrees))
	rotation = Vector3(_pitch, _yaw, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_mouse_looking = event.pressed
	elif event is InputEventMouseMotion and _mouse_looking:
		apply_look_delta(event.relative)
