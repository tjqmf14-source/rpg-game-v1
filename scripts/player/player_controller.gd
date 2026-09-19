extends CharacterBody2D
class_name PlayerController

const ENEMY_HURTBOX_MASK := 16
const HERO_SHEET := preload("res://assets/generated/characters/heroes_v1.png")
const FRAME_SIZE := Vector2i(16, 24)
const WALK_FRAME_TIME := 0.14

@export var move_speed: float = 80.0
@export var attack_damage: int = 20
@export var attack_hitbox_size: Vector2 = Vector2(20, 14)
@export var attack_offset: float = 14.0
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
var active_hero_id: String = "wanderer"
var walk_clock: float = 0.0
var walk_frame: int = 0
var visual: Sprite2D


func _ready() -> void:
	add_to_group("player")
	GameState.player_defeated.connect(_on_player_defeated)
	GameState.active_hero_changed.connect(_on_active_hero_changed)
	_ensure_visual()
	_apply_active_hero()
	_update_visual_frame()
	queue_redraw()


func _physics_process(delta: float) -> void:
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)
	dodge_cooldown_left = maxf(0.0, dodge_cooldown_left - delta)

	if attack_visual_left > 0.0:
		attack_visual_left = maxf(0.0, attack_visual_left - delta)
		queue_redraw()

	if GameState.dialogue_open or GameState.menu_open:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_walk_animation(delta, false)
		return

	if dodge_time_left > 0.0:
		dodge_time_left = maxf(0.0, dodge_time_left - delta)
		velocity = dodge_direction * move_speed * dodge_speed_multiplier
		move_and_slide()
		_update_walk_animation(delta, true)
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
	_update_walk_animation(delta, input_direction != Vector2.ZERO)


func _unhandled_input(event: InputEvent) -> void:
	if GameState.dialogue_open or GameState.menu_open:
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
	elif event.keycode >= KEY_1 and event.keycode <= KEY_4:
		var slot := int(event.keycode - KEY_1)
		if GameState.set_active_party_slot(slot):
			get_viewport().set_input_as_handled()


func _try_attack() -> void:
	if attack_cooldown_left > 0.0 or dodge_time_left > 0.0:
		return

	attack_cooldown_left = attack_cooldown
	attack_visual_left = 0.12
	queue_redraw()

	var shape := RectangleShape2D.new()
	shape.size = attack_hitbox_size

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, global_position + facing.normalized() * attack_offset)
	query.collision_mask = ENEMY_HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hits := get_world_2d().direct_space_state.intersect_shape(query, 16)
	var damaged_actor_ids: Dictionary = {}

	for hit in hits:
		var hurtbox := hit.get("collider") as Area2D
		if hurtbox == null or not hurtbox.has_method("receive_damage"):
			continue
		var actor: Node = hurtbox.call("get_actor") if hurtbox.has_method("get_actor") else null
		if actor == null:
			continue
		var actor_id := actor.get_instance_id()
		if damaged_actor_ids.has(actor_id):
			continue
		damaged_actor_ids[actor_id] = true
		hurtbox.call("receive_damage", attack_damage, self)


func _try_dodge() -> void:
	if dodge_cooldown_left > 0.0 or dodge_time_left > 0.0:
		return
	dodge_direction = facing if velocity == Vector2.ZERO else velocity.normalized()
	dodge_time_left = dodge_duration
	dodge_cooldown_left = dodge_cooldown


func take_damage(amount: int, _source: Node = null) -> void:
	if dodge_time_left > 0.0:
		return

	var hero := GameDatabase.get_hero(active_hero_id)
	var stats: Dictionary = hero.get("base_stats", {})
	var defense := int(stats.get("defense", 0)) + GameState.get_equipped_stat_bonus(active_hero_id, "defense")
	var mitigated_damage := maxi(1, amount - int(floor(float(defense) * 0.25)))
	GameState.damage_player(mitigated_damage)

	if visual != null:
		visual.modulate = Color("ffd0c9")
		get_tree().create_timer(0.08).timeout.connect(func() -> void:
			if is_instance_valid(visual):
				visual.modulate = Color.WHITE
		)


func _on_player_defeated() -> void:
	var game_root := get_tree().get_first_node_in_group("game_root")
	if game_root != null and game_root.has_method("respawn_player"):
		game_root.call_deferred("respawn_player")
	else:
		GameState.respawn_player()


func _on_active_hero_changed(_hero_id: String) -> void:
	_apply_active_hero()


func _apply_active_hero() -> void:
	active_hero_id = GameState.get_active_hero_id()
	var hero := GameDatabase.get_hero(active_hero_id)
	var stats: Dictionary = hero.get("base_stats", {})
	attack_damage = int(stats.get("attack", 16)) + GameState.get_equipped_stat_bonus(active_hero_id, "attack")
	move_speed = clampf(float(stats.get("speed", 80)), 60.0, 100.0)
	_update_visual_frame()


func _ensure_visual() -> void:
	visual = get_node_or_null("Visual") as Sprite2D
	if visual == null:
		visual = Sprite2D.new()
		visual.name = "Visual"
		add_child(visual)
	visual.texture = HERO_SHEET
	visual.region_enabled = true
	visual.centered = true
	visual.position = Vector2(0, -4)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _update_walk_animation(delta: float, moving: bool) -> void:
	if moving:
		walk_clock += delta
		if walk_clock >= WALK_FRAME_TIME:
			walk_clock = 0.0
			walk_frame = 1 if walk_frame == 2 else walk_frame + 1
	else:
		walk_clock = 0.0
		walk_frame = 0
	_update_visual_frame()


func _hero_row() -> int:
	match active_hero_id:
		"rowan_knight":
			return 1
		"mira_apprentice":
			return 2
		_:
			return 0


func _direction_index() -> int:
	if absf(facing.x) > absf(facing.y):
		return 2 if facing.x > 0.0 else 1
	return 0 if facing.y >= 0.0 else 3


func _update_visual_frame() -> void:
	if visual == null:
		return
	var column := _direction_index() * 3 + walk_frame
	visual.region_rect = Rect2(
		column * FRAME_SIZE.x,
		_hero_row() * FRAME_SIZE.y,
		FRAME_SIZE.x,
		FRAME_SIZE.y
	)


func _draw() -> void:
	if attack_visual_left > 0.0:
		var angle := facing.angle()
		draw_arc(Vector2.ZERO, 12.0, angle - 0.65, angle + 0.65, 10, Color("fff1bd"), 2.0)
