extends Node2D

@onready var _light_tile_map: TileMapLayer = $LightTileMap/TileMapLayer
@onready var _dark_tile_map: TileMapLayer = $DarkTileMap/TileMapLayer

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized)
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed()

func _update_player_state() -> void:
	if not is_instance_valid(Global.player): return

	var is_light := RealityManager.is_light_reality
	var tile_map := _light_tile_map if is_light else _dark_tile_map

	var cell := tile_map.local_to_map(tile_map.to_local(Global.player.global_position))
	var has_tile := tile_map.get_cell_source_id(cell) != -1

	var scale_factor := tile_map.tile_set.tile_size
	var tile_map_rect := tile_map.get_used_rect()
	tile_map_rect.position *= scale_factor; tile_map_rect.size *= scale_factor
	var player_is_outside_tile_map := not tile_map_rect.has_point(Global.player.global_position)

	# Retuns to the backup position in case it collides with the world when changing reality.
	# Otherwise it just saves a new backup position.
	if Global.player.hitbox.has_overlapping_bodies() or has_tile or player_is_outside_tile_map:
		Global.player.return_to_backup_position()
	else:
		Global.player.save_backup_position()

	RealityManager.update_collision_mask(Global.player)
	RealityManager.update_collision_mask(Global.player.hitbox, true)

func _on_player_initialized() -> void:
	_update_player_state()

func _on_reality_changed() -> void:
	_update_player_state()
