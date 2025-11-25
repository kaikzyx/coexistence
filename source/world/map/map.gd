extends Node2D

func _ready() -> void:
	Global.player_initialized.connect(_on_player_initialized)
	RealityManager.reality_changed.connect(_on_reality_changed)
	_on_reality_changed()

func _update_player_state() -> void:
	if not is_instance_valid(Global.player): return

	# Retuns to the backup position in case it collides with the world when changing reality.
	# Otherwise it just saves a new backup position.
	if Global.player.hitbox.has_overlapping_bodies():
		Global.player.return_to_backup_position()
	else:
		Global.player.save_backup_position()

	RealityManager.update_collision_mask(Global.player)
	RealityManager.update_collision_mask(Global.player.hitbox, true)

func _on_player_initialized() -> void:
	_update_player_state()

func _on_reality_changed() -> void:
	_update_player_state()
