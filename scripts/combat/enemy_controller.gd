extends CharacterBody2D
class_name EnemyController

const PLAYER_HURTBOX_MASK := 8
const ENEMY_SHEET := preload("res://assets/generated/monsters/enemies_v1.png")
const FRAME_SIZE := Vector2i(16, 16)

@export var monster_id: String = "meadow_slime"
@export var max_hp: int = 36
@export var move_speed: float = 30.0
@export var contact_damage: int = 6
@export var aggro_range: float = 96.0
@export var attack_range: float = 15.0
@export var attack_hitbox_radius: float = 12.0
@export var attack_cooldown: float = 0.85
@export var xp_reward: int = 10
@export var gold_reward: int = 2
@export var item_drop_id: String = ""
@export_range(0.0, 1.0, 0.05) var item_drop_chance: float = 0.0
@export var boss_mode: bool = false
@export_range(0, 2, 1) var visual_row_override: int = 0
@export var use_visual_row_override: bool = false
@export var visual_scale: float = 1.0
@export_range(0.1, 0.9, 0.05) var phase_two_hp_ratio: float = 0.5
@export var phase_two_speed_multiplier: float = 1.35
@export var phase_two_cooldown_multiplier: float = 0.72
@export var defeat_flag: String = ""
@export var guaranteed_reward_item_id: String = ""

var hp: int
var target: Node2D
var attack_cooldown_left: float = 0.0
var hurt_flash_left: float = 0.0
var animation_clock: float = 0.0
var animation_frame: int = 0
var visual: Sprite2D
var base_move_speed: float = 0.0
var base_attack_cooldown: float = 0.0
var phase_two_active: bool = false


func _ready() -> void:
	hp = max_hp
	base_move_speed = move_speed
	base_attack_cooldown = attack_cooldown
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player") as Node2D
	_ensure_visual()
	_update_visual_frame()


func _physics_process(delta: float) -> void:
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)
	animation_clock += delta
	if animation_clock >= 0.16:
		animation_clock = 0.0
		animation_frame = (animation_frame + 1) % 4
		_update_visual_frame()

	if hurt_flash_left > 0.0:
		hurt_flash_left = maxf(0.0, hurt_flash_left - delta)
		if visual != null and hurt_flash_left <= 0.0:
			visual.modulate = _boss_visual_tint()

	if GameState.dialogue_open or GameState.menu_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as Node2D
		if target == null:
			return

	var offset := target.global_position - global_position
	var distance := offset.length()

	if distance > aggro_range:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if distance > attack_range:
		velocity = offset.normalized() * move_speed
		move_and_slide()
		return

	velocity = Vector2.ZERO
	move_and_slide()

	if attack_cooldown_left <= 0.0:
		_try_attack(offset)
		attack_cooldown_left = attack_cooldown


func _try_attack(offset_to_player: Vector2) -> void:
	var shape := CircleShape2D.new()
	shape.radius = attack_hitbox_radius
	var direction := Vector2.DOWN
	if offset_to_player.length_squared() > 0.001:
		direction = offset_to_player.normalized()

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, global_position + direction * 6.0)
	query.collision_mask = PLAYER_HURTBOX_MASK
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var hits := get_world_2d().direct_space_state.intersect_shape(query, 4)
	for hit in hits:
		var hurtbox := hit.get("collider") as Area2D
		if hurtbox == null or not hurtbox.has_method("receive_damage"):
			continue
		hurtbox.call("receive_damage", contact_damage, self)
		return


func take_damage(amount: int, _source: Node = null) -> void:
	if amount <= 0 or hp <= 0:
		return
	hp = maxi(0, hp - amount)
	hurt_flash_left = 0.1
	_update_boss_phase()
	if visual != null:
		visual.modulate = Color("ffd0c9")
	if hp == 0:
		_die()


func _die() -> void:
	GameState.record_monster_defeat(monster_id)
	GameState.add_experience(xp_reward)
	GameState.add_gold(gold_reward)
	if not item_drop_id.is_empty() and randf() <= item_drop_chance:
		GameState.add_item(item_drop_id, 1)
	if not guaranteed_reward_item_id.is_empty():
		GameState.add_item(guaranteed_reward_item_id, 1)
	if not defeat_flag.is_empty():
		GameState.claim_world_flag(defeat_flag)
	queue_free()


func _ensure_visual() -> void:
	visual = get_node_or_null("Visual") as Sprite2D
	if visual == null:
		visual = Sprite2D.new()
		visual.name = "Visual"
		add_child(visual)
	visual.texture = ENEMY_SHEET
	visual.region_enabled = true
	visual.centered = true
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visual.scale = Vector2.ONE * visual_scale
	visual.modulate = _boss_visual_tint()


func _monster_row() -> int:
	if use_visual_row_override:
		return clampi(visual_row_override, 0, 2)
	match monster_id:
		"goblin_scout":
			return 1
		"restless_skeleton":
			return 2
		_:
			return 0


func _update_visual_frame() -> void:
	if visual == null:
		return
	visual.region_rect = Rect2(
		animation_frame * FRAME_SIZE.x,
		_monster_row() * FRAME_SIZE.y,
		FRAME_SIZE.x,
		FRAME_SIZE.y
	)


func _update_boss_phase() -> void:
	if not boss_mode or phase_two_active or hp <= 0:
		return
	var hp_ratio := float(hp) / float(maxi(max_hp, 1))
	if hp_ratio > phase_two_hp_ratio:
		return
	phase_two_active = true
	move_speed = base_move_speed * phase_two_speed_multiplier
	attack_cooldown = maxf(0.2, base_attack_cooldown * phase_two_cooldown_multiplier)
	if visual != null:
		visual.modulate = _boss_visual_tint()


func _boss_visual_tint() -> Color:
	if not boss_mode:
		return Color.WHITE
	if phase_two_active:
		return Color("ffb18f")
	return Color("c7b8ff")
