class_name Camera extends Camera2D

@export var target: Node2D = null

func _ready() -> void:
	if is_instance_valid(target):
		global_position = target.global_position

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, 10.0 * delta)
