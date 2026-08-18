extends Node3D


func _ready() -> void:
	$TouchInputOverlay.bind($RelayAvatar.input_router, $RelayAvatar.camera_rig)
	print("[BOOT] Aerial Vanguard Milestone 2 parkour laboratory ready")
	print("[BOOT] renderer=%s device=%s" % [RenderingServer.get_current_rendering_method(), OS.get_model_name()])
