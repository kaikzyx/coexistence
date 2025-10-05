extends Node

signal player_initialized()

var player: Player = null:
	set(value):
		assert(not is_instance_valid(player), "An player is already being referenced.")
		player = value; player_initialized.emit()
