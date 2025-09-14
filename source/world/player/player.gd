class_name Player extends CharacterBody2D

const SPEED := 100.0

func _physics_process(delta: float) -> void:
	var movement := Input.get_axis(&"move_left", &"move_right")
	velocity.x = lerp(velocity.x, movement * SPEED, 10.0 * delta)

	if movement != 0: $Sprite.flip_h = movement == -1

	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting(&"physics/2d/default_gravity") as float * delta

	move_and_slide()
