class_name QualityManager
extends Node

enum QualityTier {
	LOW,
	MEDIUM,
	HIGH,
	ULTRA,
}

@export_enum("Low", "Medium", "High", "Ultra") var default_tier: int = QualityTier.MEDIUM

var active_tier: int = QualityTier.MEDIUM


func _ready() -> void:
	add_to_group(&"quality_manager")
	var requested := OS.get_environment("AV_QUALITY").to_lower()
	active_tier = _tier_from_name(requested) if not requested.is_empty() else default_tier
	apply_tier(active_tier)


func apply_tier(tier: int) -> void:
	active_tier = clampi(tier, QualityTier.LOW, QualityTier.ULTRA)
	var viewport := get_viewport()
	match active_tier:
		QualityTier.LOW:
			viewport.scaling_3d_scale = 0.62
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		QualityTier.MEDIUM:
			viewport.scaling_3d_scale = 0.78
			viewport.msaa_3d = Viewport.MSAA_DISABLED
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		QualityTier.HIGH:
			viewport.scaling_3d_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_2X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
		QualityTier.ULTRA:
			viewport.scaling_3d_scale = 1.0
			viewport.msaa_3d = Viewport.MSAA_4X
			viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	print("[QUALITY] tier=%s scale=%.2f" % [tier_name(), viewport.scaling_3d_scale])


func tier_name() -> String:
	return ["LOW", "MEDIUM", "HIGH", "ULTRA"][active_tier]


func _tier_from_name(value: String) -> int:
	match value:
		"low":
			return QualityTier.LOW
		"high":
			return QualityTier.HIGH
		"ultra":
			return QualityTier.ULTRA
		_:
			return QualityTier.MEDIUM
