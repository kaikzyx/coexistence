class_name CameraFollower extends Camera2D

@export var target_camera: Camera2D = null

var activated := true

func _process(_delta: float) -> void:
	if activated and is_instance_valid(target_camera):
		global_transform = target_camera.global_transform
		zoom = target_camera.zoom
