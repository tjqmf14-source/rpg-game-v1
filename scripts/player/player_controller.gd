extends CharacterBody2D
class_name PlayerController

@export var move_speed: float = 80.0
@export var attack_damage: int = 20
@export var attack_range: float = 26.0
@export var attack_cooldown: float = 0.35
@export var dodge_cooldown: float = 0.7
@export var dodge_duration: float = 0.14
@export var dodge_speed_multiplier: float = 2.4

var facing: Vector2 = Vector2.DOWN
var attack_cooldown_left: float = 0.0
var attack_visual_left: float = 0.0
var dodge_cooldown_left: float = 0.0
var dodge_time_left: float = 0.0
var dodge_direction: Vector2 = Vector2.DOWN


func _ready() -> void:
	add_to_group("player")
	GameState.player_defeated.connect(_on_player_defeated)
	queue_redraw()


func _physics_process(delta: float) -> void:
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)
	dodge_cooldown_left = maxf(0.0, dodge_cooldown_left - delta)

	if attack_visual_left > 0.0:
		attack_visual_left = maxf(0.0, attack_visual_left - delta)
		queue_redraw()

	if GameState.dialogue_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if dodge_time_left > 0.0:
		dodge_time_left = maxf(0.0, dodge_time_left - delta)
		velocity = dodge_direction * move_speed * dodge_speed_multiplier
		move_and_slide()
		return

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


func _unhandled_input(event: InputEvent) -> void:
	if GameState.dialogue_open:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_try_attack()
			get_viewport().set_input_as_handled()
		return

	if not (event is InputEventKey):
		return
	if not event.pressed or event.echo:
		return

	if event.keycode == KEY_J:
		_try_attack()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_K or event.keycode == KEY_SPACE:
		_try_dodge()
		get_viewport().set_input_as_handled()


func _try_attack() -> void:
	if attack_cooldown_left > 0.0 or dodge_time_left > 0.0:
		return

	attack_cooldown_left = attack_cooldown
	attack_visual_left = 0.12
	queue_redraw()

	var best_target: Node2D = null
	var best_distance := INF

	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue

		var offset := enemy.global_position - global_position
		var distance := offset.length()
		if distance > attack_range or distance <= 0.001:
			continue

		if facing.dot(offset.normalized()) < 0.15:
			continue

		if distance < best_distance:
			best_distance = distance
			best_target = enemy

	if best_target != null and best_target.has_method("take_damage"):
		best_target.call("take_damage", attack_damage, self)


func _try_dodge() -> void:
	if dodge_cooldown_left > 0.0 or dodge_time_left > 0.0:
		return

	dodge_direction = facing
	if velocity != Vector2.ZERO:
		dodge_direction = velocity.normalized()

	dodge_time_left = dodge_duration
	dodge_cooldown_left = dodge_cooldown


func take_damage(amount: int, _source: Node = null) -> void:
	if dodge_time_left > 0.0:
		return
	GameState.damage_player(amount)
	queue_redraw()


func _on_player_defeated() -> void:
	position = Vector2(240, 135)
	GameState.set_player_position(position)
	GameState.respawn_player()


func _draw() -> void:
	# Temporary 16px-grid character. Replaced by GPT-generated production sprite.
	draw_rect(Rect2(-6, -7, 12, 13), Color("d8b56c"))
	draw_rect(Rect2(-5, -6, 10, 5), Color("e9c98a"))
	draw_rect(Rect2(-6, -7, 12, 3), Color("4a3428"))
	draw_rect(Rect2(-5, 6, 4, 2), Color("45352f"))
	draw_rect(Rect2(1, 6, 4, 2), Color("45352f"))

	var eye_offset := Vector2(signf(facing.x) * 2.0, signf(facing.y))
	draw_rect(Rect2(eye_offset.x - 2, eye_offset.y - 3, 1, 1), Color("211d1a"))
	draw_rect(Rect2(eye_offset.x + 2, eye_offset.y - 3, 1, 1), Color("211d1a"))

	if attack_visual_left > 0.0:
		var angle := facing.angle()
		draw_arc(Vector2.ZERO, 12.0, angle - 0.65, angle + 0.65, 10, Color("fff1bd"), 2.0)
