class_name State extends Node

@warning_ignore_start("unused_signal")
signal entered()
signal exited()
signal processed(delta: float)
signal physics_processed(delta: float)
@warning_ignore_restore("unused_signal")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func get_state_name() -> StringName:
	return name.replace(&"State", &"").to_snake_case()
