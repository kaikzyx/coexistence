"""
This script converts TileMapLayers between dark and light by swapping
tileset sources based on texture file names. It searches for "dark" and "light"
substrings in texture paths and replaces them accordingly.

Usage:
1. Attach this script to a Node2D containing TileMapLayer nodes.
2. Set _convert_to_light to true for dark->light conversion, false for light->dark.
3. Click the "Convert Tile Map Reality" button in the inspector to execute.

Note: This assumes all tileset textures follow naming conventions with "dark" and "light".
"""

@tool extends Node2D

@export var _convert_to_light := true

@export_tool_button(&"Convert Tile Map Reality", &"TileMapLayer")
var convert_tilemap_reality := func() -> void:
	for child in get_children(true):
		if child is TileMapLayer: _convert_tilemap_layer(child)

func _convert_tilemap_layer(tile_map_layer: TileMapLayer) -> void:
	var tile_set := tile_map_layer.tile_set

	if not tile_set: return

	var source_mapping := _create_source_mapping(tile_set)

	for cell in tile_map_layer.get_used_cells():
		var texture_path := _get_texture_path(tile_set, tile_map_layer.get_cell_source_id(cell))
		if texture_path.is_empty(): continue

		# Determine source and target reality based on conversion direction.
		var from_reality := &"dark" if _convert_to_light else &"light"
		var to_reality := &"light" if _convert_to_light else &"dark"
		var new_texture_path := texture_path.replace(from_reality, to_reality)

		# If the corresponding reality tile exists, swap it.
		if not source_mapping.has(new_texture_path): continue

		var new_source_id := source_mapping[new_texture_path]
		var atlas_coord := tile_map_layer.get_cell_atlas_coords(cell)
		var alternative_tile := tile_map_layer.get_cell_alternative_tile(cell)

		tile_map_layer.set_cell(cell, new_source_id, atlas_coord, alternative_tile)

# Creates a dictionary mapping texture paths to their source IDs.
func _create_source_mapping(tile_set: TileSet) -> Dictionary[StringName, int]:
	var dictionary: Dictionary[StringName, int] = {}

	for source_id in tile_set.get_source_count():
		var texture_path := _get_texture_path(tile_set, source_id)
		if not texture_path.is_empty(): dictionary[texture_path] = source_id

	return dictionary

func _get_texture_path(tile_set: TileSet, source_id: int) -> StringName:
	var source := tile_set.get_source(source_id)

	if source is TileSetAtlasSource:
		if source.texture: return source.texture.resource_path

	return &""
