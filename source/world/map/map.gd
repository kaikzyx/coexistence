extends Node2D

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed(RealityManager.is_light_reality)

func _on_reality_changed(is_light: bool) -> void:
	$LightTileMap.enabled = is_light; $DarkTileMap.enabled = not is_light
