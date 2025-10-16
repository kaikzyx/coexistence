extends Node2D

@onready var _background_color: ColorRect = $Background/BackgroundColor
@onready var _light_tile_map: TileMapLayer = $LightTileMap
@onready var _dark_tile_map: TileMapLayer = $DarkTileMap

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized)
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed()

func _process(_delta: float) -> void:
	var texture := RealityManager.reality_mask_texture

	_background_color.material.set_shader_parameter(&"reality_mask_texture", texture)
	_light_tile_map.material.set_shader_parameter(&"reality_mask_texture", texture)
	_dark_tile_map.material.set_shader_parameter(&"reality_mask_texture", texture)

func _update_player_state() -> void:
	if not is_instance_valid(Global.player): return

	var is_light := RealityManager.is_light_reality
	var tile_map := _light_tile_map if is_light else _dark_tile_map
	var cell := tile_map.local_to_map(tile_map.to_local(Global.player.global_position))

	# Retuns to the backup position in case it collides with the world when changing reality.
	# Otherwise it just saves a new backup position.
	if Global.player.hitbox.has_overlapping_bodies() or tile_map.get_cell_source_id(cell) == -1:
		Global.player.return_to_backup_position()
	else:
		Global.player.save_backup_position()

	RealityManager.update_collision_mask(Global.player)
	RealityManager.update_collision_mask(Global.player.hitbox, true)

func _on_player_initialized() -> void:
	_update_player_state()

func _on_reality_changed() -> void:
	_update_player_state()
