extends "res://scenes/enemies/enemy.gd"


enum _Mode {
	MOVING,
	PREPARING_ATTACK,
	ATTACKING,
	RETURNING_TO_REFERENCE,
}

@export_group("Attack")
@export var max_x_offset: float = 600.0
@export var attack_speed: float = 15
@export var attack_initial_delay: float = 0.0
@export var pre_attack_delay: float = 2.0
@export var pre_attack_max_scale: float = 1.5

var _can_attack: bool = false
var _is_attacking: bool = true
var _mode: _Mode = _Mode.MOVING
var _x_offset: float = 0.0

@onready var _timer_attack = get_node("TimerAttack")
@onready var _reference_y: float = global_position.y


func _initial_setup() -> void:
	_can_attack = false
	await get_tree().create_timer(attack_initial_delay).timeout
	_mode = _Mode.PREPARING_ATTACK
	_can_attack = true


func _shoot() -> void:
	pass


func _move(delta: float) -> void:
	match _mode:
		_Mode.MOVING: _on_moving_mode()
		_Mode.PREPARING_ATTACK: _on_preparing_attack_mode(delta)
		_Mode.ATTACKING: _on_attacking_mode()
		_Mode.RETURNING_TO_REFERENCE: _on_returning_to_reference()


func _on_moving_mode() -> void:
	look_at(global_position + _direction)
	rotate(-PI / 2.0)
	var movement: Vector2 = _direction * speed
	global_position += movement
	if _can_attack:
		_x_offset += abs(movement.x)
		if _x_offset >= max_x_offset:
			_mode = _Mode.PREPARING_ATTACK
			_x_offset = 0.0


func _on_preparing_attack_mode(delta: float) -> void:
	if is_zero_approx(pre_attack_delay):
		_mode = _Mode.ATTACKING
		return
	elif _timer_attack.is_stopped():
		_timer_attack.start(pre_attack_delay)
	var scale_factor: float = sin(_timer_attack.time_left) * pre_attack_max_scale
	scale.lerp(Vector2(scale_factor, scale_factor), delta)
	var player_pos: Vector2 = LevelManager.player.global_position
	var angle_to_player: float = global_position.angle_to_point(player_pos) - (PI / 2.0)
	global_rotation = lerp(global_rotation, angle_to_player, 0.5)


func _on_attacking_mode() -> void:
	if not _is_attacking:
		_is_attacking = true
		var angle_to_player: float = (
			get_angle_to(LevelManager.player.global_position) - (PI / 2.0)
		)
		_direction = global_position.direction_to(LevelManager.player.global_position)
	global_position += _direction * attack_speed


func _on_returning_to_reference() -> void:
	global_position += _direction * speed
	if global_position.y > _reference_y:
		global_position.y = _reference_y
		_update_direction()
		_mode = _Mode.MOVING


func _screen_exited_handler() -> void:
	if _mode == _Mode.MOVING:
		global_position.x = _x_reset_value
		return
	global_position.x = get_viewport().size.x - global_position.x
	global_position.y = 0
	if _is_attacking:
		_is_attacking = false
		_mode = _Mode.RETURNING_TO_REFERENCE


func _on_timer_attack_timeout() -> void:
	match _mode:
		_Mode.PREPARING_ATTACK:
			_mode = _Mode.ATTACKING
			_is_attacking = false

