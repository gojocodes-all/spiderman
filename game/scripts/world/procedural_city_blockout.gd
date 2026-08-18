class_name ProceduralCityBlockout
extends Node3D

@export var grid_radius := 2
@export var block_spacing := 25.0
@export var city_seed := 240818

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = city_seed
	_create_ground()
	_create_roads()
	_create_buildings()


func _create_ground() -> void:
	_create_static_box(
		"Foundation",
		Vector3(0.0, -0.3, 0.0),
		Vector3(170.0, 0.6, 170.0),
		Color("111722"),
		false
	)


func _create_roads() -> void:
	_create_visual_box(
		self,
		"NorthSouthRoad",
		Vector3(0.0, 0.015, 0.0),
		Vector3(10.0, 0.03, 160.0),
		Color("202936"),
		0.9
	)
	_create_visual_box(
		self,
		"EastWestRoad",
		Vector3(0.0, 0.02, 0.0),
		Vector3(160.0, 0.04, 10.0),
		Color("202936"),
		0.9
	)
	var marking_material := _material(Color("ffbb4d"), 0.65, true)
	for z_position in range(-76, 77, 7):
		_create_visual_box_with_material(
			self,
			"LaneMark_%s" % z_position,
			Vector3(0.0, 0.055, float(z_position)),
			Vector3(0.14, 0.03, 3.1),
			marking_material
		)


func _create_buildings() -> void:
	var palette := [Color("273548"), Color("303a47"), Color("26383b"), Color("3b3544")]
	for grid_x in range(-grid_radius, grid_radius + 1):
		for grid_z in range(-grid_radius, grid_radius + 1):
			if grid_x == 0 or grid_z == 0:
				continue
			var width := _rng.randf_range(11.0, 16.0)
			var depth := _rng.randf_range(11.0, 16.0)
			var height := _rng.randf_range(12.0, 34.0)
			var offset := Vector3(
				_rng.randf_range(-2.0, 2.0),
				height * 0.5,
				_rng.randf_range(-2.0, 2.0)
			)
			var position := Vector3(grid_x * block_spacing, 0.0, grid_z * block_spacing) + offset
			var color: Color = palette[(abs(grid_x) + abs(grid_z)) % palette.size()]
			var body := _create_static_box(
				"Tower_%s_%s" % [grid_x, grid_z],
				position,
				Vector3(width, height, depth),
				color,
				true
			)
			_add_facade_accent(body, Vector3(width, height, depth), grid_x + grid_z)
			_add_rooftop_beacon(body, height)


func _create_static_box(
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	color: Color,
	is_building: bool
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	if is_building:
		body.add_to_group(&"city_building")

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision.shape = shape
	body.add_child(collision)

	_create_visual_box(body, "Mesh", Vector3.ZERO, size_value, color, 0.78)
	return body


func _add_facade_accent(body: StaticBody3D, building_size: Vector3, index: int) -> void:
	var accent_color := Color("48d6d2") if index % 2 == 0 else Color("ff9e4a")
	var accent_height := minf(building_size.y * 0.56, 15.0)
	_create_visual_box_with_material(
		body,
		"ServiceLight",
		Vector3(0.0, 0.0, -building_size.z * 0.5 - 0.045),
		Vector3(building_size.x * 0.62, accent_height, 0.05),
		_material(accent_color.darkened(0.48), 0.5, true)
	)


func _add_rooftop_beacon(body: StaticBody3D, building_height: float) -> void:
	var beacon := MeshInstance3D.new()
	beacon.name = "RelayBeacon"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.28
	mesh.bottom_radius = 0.42
	mesh.height = 0.22
	mesh.radial_segments = 8
	mesh.material = _material(Color("68e3dd"), 0.28, true)
	beacon.mesh = mesh
	beacon.position.y = building_height * 0.5 + 0.14
	body.add_child(beacon)


func _create_visual_box(
	parent: Node,
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	color: Color,
	roughness: float
) -> MeshInstance3D:
	return _create_visual_box_with_material(
		parent,
		name_value,
		position_value,
		size_value,
		_material(color, roughness, false)
	)


func _create_visual_box_with_material(
	parent: Node,
	name_value: String,
	position_value: Vector3,
	size_value: Vector3,
	material: StandardMaterial3D
) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = name_value
	instance.position = position_value
	var mesh := BoxMesh.new()
	mesh.size = size_value
	mesh.material = material
	instance.mesh = mesh
	parent.add_child(instance)
	return instance


func _material(color: Color, roughness: float, emissive: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.12
	material.roughness = roughness
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.8
	return material
