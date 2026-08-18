class_name TraversalDebugVisualizer
extends Node3D

var _controller: ParkourTraversal
var _body: CharacterBody3D
var _movement: GroundAirMovement
var _mesh := ImmediateMesh.new()
var _mesh_instance := MeshInstance3D.new()
var _material := StandardMaterial3D.new()
var _canvas := CanvasLayer.new()
var _label := Label.new()
var _enabled := false


func _ready() -> void:
	_controller = get_parent() as ParkourTraversal
	_body = get_parent().get_parent() as CharacterBody3D
	_movement = _body.get_node("Movement") as GroundAirMovement if _body else null
	top_level = true
	global_transform = Transform3D.IDENTITY
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true
	_mesh_instance.mesh = _mesh
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh_instance.visible = false
	add_child(_mesh_instance)
	_label.position = Vector2(24.0, 92.0)
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color("8ef5e8"))
	_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.92))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)
	_canvas.add_child(_label)
	add_child(_canvas)
	_canvas.visible = false
	set_process(true)


func _process(_delta: float) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed(&"traversal_debug"):
		set_debug_enabled(not _enabled)
	if not _enabled:
		return
	_update_geometry()
	_update_hud()


func set_debug_enabled(enabled: bool) -> void:
	_enabled = enabled and OS.is_debug_build()
	_mesh_instance.visible = _enabled
	_canvas.visible = _enabled
	if not _enabled:
		_mesh.clear_surfaces()


func is_debug_enabled() -> bool:
	return _enabled


func _update_geometry() -> void:
	_mesh.clear_surfaces()
	if _controller == null:
		return
	var probe := _controller.current_probe()
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _material)
	_add_line(probe.lower_ray_start, probe.lower_ray_end, Color("58d6ff"))
	_add_line(probe.upper_ray_start, probe.upper_ray_end, Color("3f89ff"))
	if probe.has_obstacle:
		_add_line(probe.wall_point, probe.wall_point + probe.wall_normal * 1.2, Color("ff9f43"))
	if probe.has_top:
		_add_line(probe.top_ray_start, probe.top_ray_end, Color("d072ff"))
		_add_cross(probe.top_point, 0.18, Color("f08cff"))
		_add_cross(probe.mantle_target, 0.24, Color("65f28b") if probe.destination_clear else Color("ff5364"))
	if probe.vault_landing_found:
		_add_line(probe.landing_ray_start, probe.landing_ray_end, Color("ffd166"))
		_add_cross(probe.vault_target, 0.24, Color("ffe28a"))
	_mesh.surface_end()


func _update_hud() -> void:
	if _body == null or _controller == null:
		return
	var velocity := _body.velocity
	var speed := Vector2(velocity.x, velocity.z).length()
	var movement_state := _movement.state_machine.state_name() if _movement else &"unknown"
	var effective_state := _controller.state_name()
	if effective_state == &"idle":
		effective_state = movement_state
	_label.text = (
		"TRAVERSAL DEBUG [F8]\n"
		+ "STATE: %s\n" % effective_state
		+ "SPEED: %.2f m/s\n" % speed
		+ "VELOCITY: (%.2f, %.2f, %.2f)\n" % [velocity.x, velocity.y, velocity.z]
		+ "SURFACE: %s\n" % (_controller.selected_surface if not _controller.selected_surface.is_empty() else &"none")
		+ "WALL NORMAL: (%.2f, %.2f, %.2f)\n" % [
			_controller.current_wall_normal.x,
			_controller.current_wall_normal.y,
			_controller.current_wall_normal.z,
		]
		+ "TRAVERSAL ACTION: %s\n" % _controller.last_action
		+ "EXIT: %s  QUERIES: %d" % [
			_controller.last_exit_reason,
			_controller.detector.last_queries_per_probe,
		]
	)


func _add_line(start: Vector3, end: Vector3, color: Color) -> void:
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(start)
	_mesh.surface_set_color(color)
	_mesh.surface_add_vertex(end)


func _add_cross(center: Vector3, radius: float, color: Color) -> void:
	_add_line(center - Vector3.RIGHT * radius, center + Vector3.RIGHT * radius, color)
	_add_line(center - Vector3.UP * radius, center + Vector3.UP * radius, color)
	_add_line(center - Vector3.FORWARD * radius, center + Vector3.FORWARD * radius, color)
