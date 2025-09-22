extends Node2D

func _ready() -> void:
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed()

func _on_reality_changed() -> void:
	var is_light := RealityManager.is_light_reality
	$LightTileMap.visible = is_light; $DarkTileMap.visible = not is_light
