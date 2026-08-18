class_name MovementTraversalLab
extends Node3D

var _materials: Dictionary = {}
var _feature_count := 0


func _ready() -> void:
	_create_foundation_and_flat_zones()
	_create_step_and_stair_zone()
	_create_slope_zone()
	_create_alley_and_corner_zone()
	_create_rooftop_and_gap_zone()
	_create_wall_and_pipe_zone()
	_create_narrow_platform_zone()
	_create_camera_collision_bay()
	_create_landing_markers()
	print("[LAB] Movement traversal laboratory ready features=%d markers=%d" % [
		_feature_count,
		get_tree().get_nodes_in_group(&"lab_marker").size(),
	])


func marker(marker_name: StringName) -> Marker3D:
	return get_node_or_null(NodePath("Markers/%s" % marker_name)) as Marker3D


func feature_count() -> int:
	return _feature_count


func _create_foundation_and_flat_zones() -> void:
	_create_static_box(
		"Foundation",
		Vector3(0.0, -0.3, 0.0),
		Vector3(180.0, 0.6, 180.0),
		Color("111824"),
		"baseline floor, edge stability, and unrestricted acceleration",
		[&"lab_flat"]
	)
	_create_visual_box(
		"FlatResponseLane",
		Vector3(0.0, 0.012, 24.0),
		Vector3(14.0, 0.02, 28.0),
		Color("19333d")
	)
	_create_visual_box(
		"DirectionChangeLane",
		Vector3(-17.0, 0.014, 29.0),
		Vector3(18.0, 0.022, 7.0),
		Color("283249")
	)
	_add_marker(&"SpawnFlat", Vector3(0.0, 1.05, 34.0), Vector3.FORWARD)
	_add_marker(&"FlatRunStart", Vector3(0.0, 1.05, 34.0), Vector3.FORWARD)
	_add_marker(&"DirectionChangeStart", Vector3(-17.0, 1.05, 29.0), Vector3.RIGHT)


func _create_step_and_stair_zone() -> void:
	var step_heights: Array[float] = [0.10, 0.20, 0.32, 0.48]
	for index in step_heights.size():
		var height := step_heights[index]
		_create_static_box(
			"StepProbe_%02dcm" % int(height * 100.0),
			Vector3(-7.0, height * 0.5, 25.0 - index * 3.0),
			Vector3(5.0, height, 1.2),
			Color("3c6570") if height <= 0.38 else Color("704448"),
			"bounded small-step traversal and over-height rejection",
			[&"lab_step"]
		)
	_add_marker(&"StepStart", Vector3(-7.0, 1.05, 28.0), Vector3.FORWARD)

	_create_stairs("ShortStairs", Vector3(-18.0, 0.0, 20.0), 7, 0.18, 0.68, 5.0)
	_create_stairs("LongStairs", Vector3(-30.0, 0.0, 24.0), 18, 0.18, 0.62, 4.5)
	_add_marker(&"ShortStairsStart", Vector3(-18.0, 1.05, 22.0), Vector3.FORWARD)
	_add_marker(&"LongStairsStart", Vector3(-30.0, 1.05, 26.0), Vector3.FORWARD)


func _create_slope_zone() -> void:
	_create_ramp(
		"GradualRamp18",
		Vector3(14.0, 0.0, 23.0),
		14.0,
		5.5,
		18.0,
		Color("365c50"),
		[&"lab_ramp", &"lab_walkable_slope"]
	)
	_create_ramp(
		"SteepRamp38",
		Vector3(25.0, 0.0, 22.0),
		10.0,
		5.0,
		38.0,
		Color("6a5a3b"),
		[&"lab_ramp", &"lab_walkable_slope"]
	)
	_create_ramp(
		"RejectedRamp55",
		Vector3(35.0, 0.0, 22.0),
		8.0,
		5.0,
		55.0,
		Color("704448"),
		[&"lab_ramp", &"lab_rejected_slope"]
	)
	_add_marker(&"GradualRampStart", Vector3(14.0, 1.05, 25.0), Vector3.FORWARD)
	_add_marker(&"SteepRampStart", Vector3(25.0, 1.05, 24.0), Vector3.FORWARD)


func _create_alley_and_corner_zone() -> void:
	_create_static_box(
		"TightAlleyLeft",
		Vector3(43.0, 2.5, 5.0),
		Vector3(1.0, 5.0, 30.0),
		Color("303b4a"),
		"tight-space wall sliding and camera compression",
		[&"lab_alley", &"lab_wall"]
	)
	_create_static_box(
		"TightAlleyRight",
		Vector3(46.0, 2.5, 5.0),
		Vector3(1.0, 5.0, 30.0),
		Color("303b4a"),
		"tight-space wall sliding and camera compression",
		[&"lab_alley", &"lab_wall"]
	)
	_create_static_box(
		"NarrowAlleyLeft",
		Vector3(52.0, 2.5, 5.0),
		Vector3(1.0, 5.0, 24.0),
		Color("3b3548"),
		"near-capsule-clearance collision stability",
		[&"lab_alley", &"lab_narrow_space"]
	)
	_create_static_box(
		"NarrowAlleyRight",
		Vector3(54.35, 2.5, 5.0),
		Vector3(1.0, 5.0, 24.0),
		Color("3b3548"),
		"near-capsule-clearance collision stability",
		[&"lab_alley", &"lab_narrow_space"]
	)
	_create_static_box(
		"CornerTrapFront",
		Vector3(35.0, 1.5, -4.0),
		Vector3(12.0, 3.0, 0.8),
		Color("563e4c"),
		"acute direction reversal against a blocking wall",
		[&"lab_corner", &"lab_wall"]
	)
	_create_static_box(
		"CornerTrapSide",
		Vector3(40.6, 1.5, -9.5),
		Vector3(0.8, 3.0, 11.8),
		Color("563e4c"),
		"corner depenetration and input reversal",
		[&"lab_corner", &"lab_wall"]
	)
	_add_marker(&"TightAlleyStart", Vector3(44.5, 1.05, 18.0), Vector3.FORWARD)
	_add_marker(&"WallCollisionStart", Vector3(35.0, 1.05, 2.5), Vector3.FORWARD)


func _create_rooftop_and_gap_zone() -> void:
	_create_static_box(
		"SmallRooftop",
		Vector3(-16.0, 2.25, -19.0),
		Vector3(8.0, 0.5, 8.0),
		Color("394a55"),
		"small elevated turning area and edge behavior",
		[&"lab_rooftop", &"lab_small_rooftop"]
	)
	_create_ramp(
		"SmallRoofAccess",
		Vector3(-16.0, 0.0, -12.2),
		7.0,
		3.2,
		20.9,
		Color("365c50"),
		[&"lab_ramp", &"lab_roof_access"]
	)
	_create_static_box(
		"LargeRooftop",
		Vector3(1.0, 3.75, -21.0),
		Vector3(18.0, 0.5, 13.0),
		Color("3e4c5b"),
		"large elevated sprint area, run-off edge, and landing",
		[&"lab_rooftop", &"lab_large_rooftop"]
	)
	_create_ramp(
		"LargeRoofAccess",
		Vector3(7.0, 0.0, -8.0),
		10.5,
		4.0,
		22.4,
		Color("365c50"),
		[&"lab_ramp", &"lab_roof_access"]
	)
	_create_static_box(
		"GapPlatformA",
		Vector3(14.0, 2.25, -38.0),
		Vector3(7.0, 0.5, 8.0),
		Color("3f5663"),
		"repeatable short-gap running jump takeoff",
		[&"lab_gap", &"lab_rooftop"]
	)
	_create_static_box(
		"GapPlatformB",
		Vector3(14.0, 3.25, -49.0),
		Vector3(7.0, 0.5, 8.0),
		Color("465967"),
		"elevated short-gap landing target",
		[&"lab_gap", &"lab_rooftop"]
	)
	_create_static_box(
		"GapPlatformC",
		Vector3(14.0, 4.25, -62.0),
		Vector3(9.0, 0.5, 9.0),
		Color("4d5d6b"),
		"longer-gap landing target and elevation change",
		[&"lab_gap", &"lab_rooftop"]
	)
	_add_marker(&"RoofEdgeStart", Vector3(1.0, 5.05, -19.0), Vector3.FORWARD)
	_add_marker(&"GapStart", Vector3(14.0, 3.55, -36.0), Vector3.FORWARD)


func _create_wall_and_pipe_zone() -> void:
	var wall_heights: Array[float] = [0.35, 0.75, 1.4, 4.0]
	for index in wall_heights.size():
		var height := wall_heights[index]
		_create_static_box(
			"Wall_%02d" % index,
			Vector3(-45.0 + index * 7.0, height * 0.5, -6.0),
			Vector3(5.0, height, 0.55),
			Color("465362") if height < 1.0 else Color("3d4654"),
			"stepable, blocking, and future parkour wall height comparison",
			[&"lab_wall", &"lab_height_reference"]
		)
	_create_static_cylinder(
		"LowPipe",
		Vector3(-44.0, 0.28, 5.0),
		0.28,
		7.0,
		Vector3(0.0, 0.0, 90.0),
		Color("49717a"),
		"rounded low-obstacle collision and step rejection",
		[&"lab_pipe", &"lab_obstacle"]
	)
	_create_static_cylinder(
		"RaisedPipe",
		Vector3(-34.0, 0.65, 5.0),
		0.32,
		7.0,
		Vector3(0.0, 0.0, 90.0),
		Color("805d3e"),
		"rounded jump obstacle and landing collision",
		[&"lab_pipe", &"lab_obstacle"]
	)
	_add_marker(&"PipeStart", Vector3(-44.0, 1.05, 10.0), Vector3.FORWARD)


func _create_narrow_platform_zone() -> void:
	for index in 4:
		_create_static_box(
			"NarrowPlatform_%02d" % index,
			Vector3(29.0, 0.65 + index * 0.55, -28.0 - index * 8.5),
			Vector3(1.35, 1.3 + index * 1.1, 7.0),
			Color("355361"),
			"narrow-platform steering, edge stability, and elevation transfer",
			[&"lab_narrow_platform", &"lab_elevation"]
		)
	_add_marker(&"NarrowPlatformStart", Vector3(29.0, 2.35, -25.5), Vector3.FORWARD)


func _create_camera_collision_bay() -> void:
	_create_static_box(
		"CameraBayBackWall",
		Vector3(63.0, 2.5, 29.0),
		Vector3(11.0, 5.0, 0.8),
		Color("394155"),
		"camera spring-arm obstruction behind the player",
		[&"lab_camera_collision", &"lab_wall"]
	)
	_create_static_box(
		"CameraBayLeftWall",
		Vector3(57.9, 2.5, 23.5),
		Vector3(0.8, 5.0, 11.8),
		Color("394155"),
		"camera side obstruction in a compact bay",
		[&"lab_camera_collision", &"lab_wall"]
	)
	_create_static_box(
		"CameraBayRightWall",
		Vector3(68.1, 2.5, 23.5),
		Vector3(0.8, 5.0, 11.8),
		Color("394155"),
		"camera side obstruction in a compact bay",
		[&"lab_camera_collision", &"lab_wall"]
	)
	_add_marker(&"CameraCollisionStart", Vector3(63.0, 1.05, 26.0), Vector3.FORWARD)


func _create_landing_markers() -> void:
	_add_marker(&"SoftLandingDrop", Vector3(-58.0, 3.2, 18.0), Vector3.FORWARD)
	_add_marker(&"HardLandingDrop", Vector3(-58.0, 9.0, 4.0), Vector3.FORWARD)


func _create_stairs(
	name_prefix: String,
	start: Vector3,
	step_count: int,
	rise: float,
	tread_depth: float,
	width: float
) -> void:
	for index in step_count:
		var height := rise * float(index + 1)
		_create_static_box(
			"%s_%02d" % [name_prefix, index],
			start + Vector3(0.0, height * 0.5, -(float(index) + 0.5) * tread_depth),
			Vector3(width, height, tread_depth),
			Color("3d5961"),
			"stair ascent, descent, floor snapping, and cadence stability",
			[&"lab_stairs"]
		)


func _create_ramp(
	name_value: String,
	low_end: Vector3,
	length: float,
	width: float,
	angle_degrees: float,
	color: Color,
	groups: Array[StringName]
) -> StaticBody3D:
	var angle := deg_to_rad(angle_degrees)
	var thickness := 0.38
	var center := low_end + Vector3(
		0.0,
		sin(angle) * length * 0.5 - cos(angle) * thickness * 0.5,
		-cos(angle) * length * 0.5
	)
	var body := _create_static_box(
		name_value,
		center,
		Vector3(width, thickness, length),
		color,
		"walkable and rejected slope-angle behavior",
		groups
	)
	body.rotation_degrees.x = angle_degrees
	return body


func _create_static_box(
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	color: Color,
	purpose: String,
	groups: Array[StringName]
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	body.collision_layer = 1
	body.collision_mask = 1
	body.set_meta(&"test_purpose", purpose)
	body.add_to_group(&"lab_feature")
	for group_name in groups:
		body.add_to_group(group_name)
	add_child(body)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision.shape = shape
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = _material(color)
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)
	_feature_count += 1
	return body


func _create_static_cylinder(
	name_value: String,
	position_value: Vector3,
	radius: float,
	height: float,
	rotation_degrees_value: Vector3,
	color: Color,
	purpose: String,
	groups: Array[StringName]
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	body.rotation_degrees = rotation_degrees_value
	body.collision_layer = 1
	body.collision_mask = 1
	body.set_meta(&"test_purpose", purpose)
	body.add_to_group(&"lab_feature")
	for group_name in groups:
		body.add_to_group(group_name)
	add_child(body)

	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	collision.shape = shape
	body.add_child(collision)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.material = _material(color)
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)
	_feature_count += 1
	return body


func _create_visual_box(name_value: String, position_value: Vector3, size_value: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = _material(color)
	instance.mesh = mesh
	add_child(instance)


func _add_marker(marker_name: StringName, position_value: Vector3, forward: Vector3) -> void:
	var marker_root := get_node_or_null("Markers") as Node3D
	if marker_root == null:
		marker_root = Node3D.new()
		marker_root.name = "Markers"
		add_child(marker_root)
	var marker_node := Marker3D.new()
	marker_node.name = marker_name
	marker_node.position = position_value
	marker_node.set_meta(&"forward", forward)
	marker_node.add_to_group(&"lab_marker")
	marker_root.add_child(marker_node)


func _material(color: Color) -> StandardMaterial3D:
	var key := color.to_html()
	if _materials.has(key):
		return _materials[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.08
	material.roughness = 0.82
	_materials[key] = material
	return material
