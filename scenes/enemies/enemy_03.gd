extends "res://scenes/enemies/enemy.gd"


enum _Mode {
	MOVING,
	FALLING,
	RISING,
	ATTACKING,
}

@export_group("Movement")
@export var vertical_speed: float = 20

@export_group("Attack")
@export var max_x_offset: float = 100.0
@export var max_y_limit: float = 600.0
@export var attack_speed: float = 30
@export var attack_scale: float = 4
@export var attack_initial_delay: float = 0.0

var _can_attack: bool = false
var _x_offset: float = 0.0
var _mode: _Mode = _Mode.MOVING
var _tween: Tween = null

@onready var _original_scale = scale
@onready var _reference_y: float = global_position.y


func _initial_setup() -> void:
	_can_attack = false
	await get_tree().create_timer(attack_initial_delay).timeout
	_mode = _Mode.FALLING
	_can_attack = true


func _move(_delta: float) -> void:
	match _mode:
		_Mode.MOVING: _on_moving_mode()
		_Mode.FALLING: _on_falling_mode()
		_Mode.RISING: _on_rising_mode()
		_Mode.ATTACKING: _on_attacking_mode()


func _on_moving_mode() -> void:
	var movement: Vector2 = _direction * speed
	global_position += movement
	if _can_attack:
		_x_offset += abs(movement.x)
		if _x_offset >= max_x_offset:
			_mode = _Mode.FALLING
			_x_offset = 0.0


func _on_falling_mode() -> void:
	global_position += Vector2.DOWN * vertical_speed
	if global_position.y >= max_y_limit:
		_mode = _Mode.ATTACKING
		global_position.y = max_y_limit


func _shoot() -> void:
	pass


func _on_attacking_mode() -> void:
	if _tween or is_zero_approx(attack_speed):
		return
	var duration: float = attack_scale / attack_speed
	#_tween = get_tree().create_tween()
	await _grow(duration)
	await _shrink(duration)
	#_tween.kill()
	#_tween = null
	_mode = _Mode.RISING


func _on_rising_mode() -> void:
	global_position -= Vector2.DOWN * vertical_speed
	if global_position.y <= _reference_y:
		_mode = _Mode.MOVING
		global_position.y = _reference_y


func _grow(duration: float) -> void:
	_tween = get_tree().create_tween()
	_tween.set_trans(Tween.TRANS_ELASTIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE * attack_scale, duration)
	_tween.play()
	await _tween.finished
	_tween.kill()
	_tween = null
	return


func _shrink(duration: float) -> void:
	_tween = get_tree().create_tween()
	_tween.set_trans(Tween.TRANS_BOUNCE)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", _original_scale, duration)
	_tween.play()
	await _tween.finished
	_tween.kill()
	_tween = null
	return

