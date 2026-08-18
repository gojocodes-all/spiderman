class_name RelayAvatar
extends CharacterBody3D

@export var visual_turn_speed := 10.0

@onready var input_router: PlayerInputRouter = $InputRouter
@onready var movement_component: GroundAirMovement = $Movement
@onready var camera_rig: ThirdPersonCameraRig = $CameraRig
@onready var visual_root: Node3D = $VisualRoot


func _ready() -> void:
	add_to_group(&"player")


func _physics_process(delta: float) -> void:
	var snapshot := input_router.consume_snapshot()
	var wish_direction := camera_rig.world_direction_from_input(snapshot["move"])
	movement_component.simulate(
		self,
		wish_direction,
		bool(snapshot["jump"]),
		bool(snapshot["burst"]),
		delta
	)
	_face_wish_direction(wish_direction, delta)


func _face_wish_direction(wish_direction: Vector3, delta: float) -> void:
	if wish_direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(-wish_direction.x, -wish_direction.z)
	visual_root.rotation.y = lerp_angle(
		visual_root.rotation.y,
		target_yaw,
		clampf(visual_turn_speed * delta, 0.0, 1.0)
	)
