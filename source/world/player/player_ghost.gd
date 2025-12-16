class_name PlayerGhost extends Node2D

var following := true

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized); _on_player_initialized()
	_update_animated_sprite()

func _process(_delta: float) -> void:
	_update_animated_sprite()

func _update_animated_sprite() -> void:
	if is_instance_valid(Global.player):
		if following:
			_animated_sprite.global_transform = Global.player.animated_sprite.global_transform
		_animated_sprite.offset = Global.player.animated_sprite.offset

func _on_player_initialized() -> void:
	if not is_instance_valid(Global.player): return
	var player := Global.player

	player.direction_changed.connect(_on_player_direction_changed)
	player.animated_sprite.sprite_frames_changed.connect(_on_player_sprite_frames_changed)
	player.animated_sprite.animation_changed.connect(_on_player_animation_changed)
	player.animated_sprite.frame_changed.connect(_on_player_frame_changed)

	_on_player_direction_changed()
	_on_player_sprite_frames_changed()
	_on_player_animation_changed()
	_on_player_frame_changed()

func _on_player_direction_changed() -> void:
	_animated_sprite.flip_h = Global.player.direction == -1

func _on_player_sprite_frames_changed() -> void:
	_animated_sprite.sprite_frames = Player.get_sprite_frames(
		RealityManager.get_opposite_reality(RealityManager.current_reality))

func _on_player_animation_changed() -> void:
	_animated_sprite.animation = Global.player.animated_sprite.animation

func _on_player_frame_changed() -> void:
	_animated_sprite.frame = Global.player.animated_sprite.frame
