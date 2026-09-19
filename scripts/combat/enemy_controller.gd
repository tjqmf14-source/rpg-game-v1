extends CharacterBody2D
class_name EnemyController

@export var monster_id: String = "meadow_slime"
@export var max_hp: int = 36
@export var move_speed: float = 30.0
@export var contact_damage: int = 6
@export var aggro_range: float = 96.0
@export var attack_range: float = 15.0
@export var attack_cooldown: float = 0.85
@export var xp_reward: int = 10
@export var gold_reward: int = 2
@export var item_drop_id: String = ""
@export_range(0.0, 1.0, 0.05) var item_drop_chance: float = 0.0

var hp: int
var target: Node2D
var attack_cooldown_left: float = 0.0
var hurt_flash_left: float = 0.0


func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player") as Node2D
	queue_redraw()


func _physics_process(delta: float) -> void:
	attack_cooldown_left = maxf(0.0, attack_cooldown_left - delta)

	if hurt_flash_left > 0.0:
		hurt_flash_left = maxf(0.0, hurt_flash_left - delta)
		queue_redraw()

	if GameState.dialogue_open:
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

	if attack_cooldown_left <= 0.0 and target.has_method("take_damage"):
		target.call("take_damage", contact_damage, self)
		attack_cooldown_left = attack_cooldown


func take_damage(amount: int, _source: Node = null) -> void:
	if amount <= 0 or hp <= 0:
		return

	hp = maxi(0, hp - amount)
	hurt_flash_left = 0.1
	queue_redraw()

	if hp == 0:
		_die()


func _die() -> void:
	GameState.record_monster_defeat(monster_id)
	GameState.add_experience(xp_reward)
	GameState.add_gold(gold_reward)

	if not item_drop_id.is_empty() and randf() <= item_drop_chance:
		GameState.add_item(item_drop_id, 1)

	queue_free()


func _draw() -> void:
	var base_color := Color("79ad42")
	var accent := Color("315727")

	match monster_id:
		"goblin_scout":
			base_color = Color("728646")
			accent = Color("3c4428")
		"restless_skeleton":
			base_color = Color("d2c5a5")
			accent = Color("6d6659")
		_:
			base_color = Color("79ad42")
			accent = Color("315727")

	if hurt_flash_left > 0.0:
		base_color = Color("f6d0c3")

	if monster_id == "meadow_slime":
		draw_circle(Vector2(0, 2), 6.0, base_color)
		draw_rect(Rect2(-5, 4, 10, 3), accent)
		draw_rect(Rect2(-3, 0, 1, 1), Color("182018"))
		draw_rect(Rect2(2, 0, 1, 1), Color("182018"))
	elif monster_id == "restless_skeleton":
		draw_circle(Vector2(0, -3), 4.0, base_color)
		draw_rect(Rect2(-4, 1, 8, 7), base_color)
		draw_rect(Rect2(-2, -4, 1, 1), Color("25231f"))
		draw_rect(Rect2(1, -4, 1, 1), Color("25231f"))
		draw_line(Vector2(4, 0), Vector2(8, -5), accent, 2.0)
	else:
		draw_circle(Vector2(0, -3), 4.0, base_color)
		draw_rect(Rect2(-5, 1, 10, 7), accent)
		draw_polygon(
			PackedVector2Array([Vector2(-4, -4), Vector2(-8, -6), Vector2(-4, -1)]),
			PackedColorArray([base_color])
		)
		draw_polygon(
			PackedVector2Array([Vector2(4, -4), Vector2(8, -6), Vector2(4, -1)]),
			PackedColorArray([base_color])
		)
		draw_line(Vector2(4, 2), Vector2(8, -2), Color("b8b2a5"), 2.0)
