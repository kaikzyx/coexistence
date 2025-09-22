extends Node2D

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed(RealityManager.is_light_reality)

func _on_reality_changed(is_light: bool) -> void:
	$LightTileMap.visible = is_light; $DarkTileMap.visible = not is_light
