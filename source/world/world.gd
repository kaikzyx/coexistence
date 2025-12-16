extends Node2D

static var _player_scene: PackedScene = preload("res://source/world/player/player.tscn")
static var _player_ghost_scene: PackedScene = preload("res://source/world/player/player_ghost.tscn")

var _player_ghost: PlayerGhost = null
var _light_player_spawn: Marker2D = null
var _dark_player_spawn: Marker2D = null

@onready var _light_camera: CameraFollower = $DarkViewport/CameraFollower
@onready var _dark_camera: CameraFollower = $LightViewport/CameraFollower
@onready var _light_viewport: SubViewport = $LightViewport
@onready var _dark_viewport: SubViewport = $DarkViewport

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed); _on_viewport_size_changed()
	RealityManager.reality_changed.connect(_update_player_and_player_ghost_state);
	RealityManager.reality_mask_finished.connect(_on_reality_mask_finished)

	# Share the texture with the reality system for shader effects.
	RealityManager.light_viewport_texture = _light_viewport.get_texture()
	RealityManager.dark_viewport_texture = _dark_viewport.get_texture()

	_light_player_spawn = _light_viewport.find_child(&"PlayerSpawn")
	assert(is_instance_valid(_light_player_spawn),"There is no 'PlayerSpawn' node in light reality.")
	_dark_player_spawn = _dark_viewport.find_child(&"PlayerSpawn")
	assert(is_instance_valid(_dark_player_spawn), "There is no 'PlayerSpawn' node in dark reality.")

	_setup_player_and_player_ghost()
	_update_player_and_player_ghost_state()

func _setup_player_and_player_ghost() -> void:
	var is_light := RealityManager.current_reality == RealityManager.Type.LIGHT

	# Player setup.
	var player: Player = _player_scene.instantiate()
	player.back_to_backup_position.connect(_on_player_back_to_backup_position)
	(_dark_player_spawn if is_light else _light_player_spawn).add_child(player)

	# Player ghost setup.
	_player_ghost = _player_ghost_scene.instantiate()
	(_light_player_spawn if is_light else _dark_player_spawn).add_child(_player_ghost)

func _swap_player_with_player_ghost() -> void:
	if not is_instance_valid(Global.player) or not is_instance_valid(_player_ghost): return

	var player_parent := Global.player.get_parent()
	var player_ghost_parent := _player_ghost.get_parent()

	player_parent.remove_child(Global.player); player_ghost_parent.add_child(Global.player)
	player_ghost_parent.remove_child(_player_ghost); player_parent.add_child(_player_ghost)

func _set_follow_behavior(enable: bool) -> void:
	if is_instance_valid(_player_ghost): _player_ghost.freeze = not enable
	var is_light := RealityManager.current_reality == RealityManager.Type.LIGHT
	(_light_camera if is_light else _dark_camera).activated = enable

func _update_player_and_player_ghost_state() -> void:
	if is_instance_valid(Global.player): _swap_player_with_player_ghost()

func _on_viewport_size_changed() -> void:
	var size := get_viewport_rect().size
	_light_viewport.size = size; _dark_viewport.size = size

func _on_reality_mask_finished() -> void:
	_set_follow_behavior(true)

func _on_player_back_to_backup_position(_from: Vector2, _to: Vector2) -> void:
	_set_follow_behavior(false)
