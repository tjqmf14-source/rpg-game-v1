extends CharacterBody2D
class_name PlayerController

@export var move_speed: float = 80.0

var facing: Vector2 = Vector2.DOWN


func _ready() -> void:
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var input_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if Input.is_physical_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		input_direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		input_direction.y += 1.0

	input_direction = input_direction.limit_length(1.0)

	if input_direction != Vector2.ZERO:
		facing = input_direction.normalized()
		velocity = input_direction * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func _draw() -> void:
	# Temporary 16px-grid character. Replaced by Sunnyside sprites later.
	draw_rect(Rect2(-6, -7, 12, 13), Color("d8b56c"))
	draw_rect(Rect2(-5, -6, 10, 5), Color("e9c98a"))
	draw_rect(Rect2(-6, -7, 12, 3), Color("4a3428"))
	draw_rect(Rect2(-5, 6, 4, 2), Color("45352f"))
	draw_rect(Rect2(1, 6, 4, 2), Color("45352f"))

	var eye_offset := Vector2(signf(facing.x) * 2.0, signf(facing.y))
	draw_rect(Rect2(eye_offset.x - 2, eye_offset.y - 3, 1, 1), Color("211d1a"))
	draw_rect(Rect2(eye_offset.x + 2, eye_offset.y - 3, 1, 1), Color("211d1a"))
