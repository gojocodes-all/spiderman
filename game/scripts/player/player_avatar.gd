class_name RelayAvatar
extends CharacterBody3D

@onready var input_router: PlayerInputRouter = $InputRouter
@onready var movement_component: GroundAirMovement = $Movement
@onready var movement_state_machine: MovementStateMachine = $Movement/StateMachine
@onready var camera_rig: ThirdPersonCameraRig = $CameraRig
@onready var visual_root: Node3D = $VisualRoot


func _ready() -> void:
	add_to_group(&"player")


func _physics_process(delta: float) -> void:
	var snapshot: PlayerInputSnapshot = input_router.consume_snapshot()
	var wish_direction := camera_rig.world_direction_from_input(snapshot.move)
	movement_component.simulate(
		self,
		wish_direction,
		snapshot.jump_pressed,
		snapshot.sprint_held,
		snapshot.walk_held,
		snapshot.burst_pressed,
		delta
	)
	_face_wish_direction(wish_direction, delta)
	camera_rig.set_motion_context(
		Vector3(velocity.x, 0.0, velocity.z),
		wish_direction,
		snapshot.move.length()
	)


func reset_motion_at(world_position: Vector3, facing_direction: Vector3 = Vector3.FORWARD) -> void:
	global_position = world_position
	movement_component.reset_runtime_state(self)
	input_router.clear_touch_input()
	var flat_facing := Vector3(facing_direction.x, 0.0, facing_direction.z)
	if flat_facing.is_zero_approx():
		flat_facing = Vector3.FORWARD
	visual_root.rotation.y = atan2(-flat_facing.x, -flat_facing.z)
	camera_rig.snap_to_target(flat_facing)


func _face_wish_direction(wish_direction: Vector3, delta: float) -> void:
	if wish_direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(-wish_direction.x, -wish_direction.z)
	visual_root.rotation.y = rotate_toward(
		visual_root.rotation.y,
		target_yaw,
		movement_component.tuning.rotation_speed_radians(is_on_floor()) * delta
	)
