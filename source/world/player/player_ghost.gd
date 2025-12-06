class_name PlayerGhost extends Node2D

var following := true

@onready var _sprite: Sprite2D = $Sprite

func _ready() -> void:
	_update()

func _process(_delta: float) -> void:
	_update()

func _update() -> void:
	if not is_instance_valid(Global.player): return
	var player_sprite := Global.player.sprite

	if following: _sprite.global_transform = player_sprite.global_transform
	_sprite.texture = Player.dark_texture if RealityManager.is_light_reality else Player.light_texture
	_sprite.flip_h = player_sprite.flip_h
