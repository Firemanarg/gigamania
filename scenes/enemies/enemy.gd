extends Node2D


signal died(score_value: int)

enum _DirectionValues {
	RIGHT,
	LEFT,
}

@export_group("Score")
@export var score_value: int = 10

@export_group("Movement")
@export var speed: float = 2.0
@export var direction: _DirectionValues = _DirectionValues.RIGHT:
	set = _set_direction

@export_group("Shoot")
@export var projectile_speed: float = 7.0

@export_subgroup("Timed Shoot")
@export var enable_timed_shoot: bool = true
@export var shoot_delay: float = 5.0
@export var initial_delay: float = 0.0

var _x_reset_value: float = 0.0
var _direction: Vector2 = Vector2.RIGHT

@onready var timer_shoot = get_node("TimerShoot")


func _ready() -> void:
	_update_direction()
	_initial_setup()
	await get_tree().create_timer(LevelManager.stage_initial_delay).timeout
	if enable_timed_shoot:
		await get_tree().create_timer(initial_delay).timeout
		_shoot()
		timer_shoot.start(shoot_delay)


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	_move(delta)


func die() -> void:
	died.emit(score_value)
	queue_free()


# Overridable.
func _initial_setup() -> void:
	pass


# Overridable.
func _shoot() -> void:
	var laser: Area2D = _get_laser_scene().instantiate()
	LevelManager.add_laser(laser, global_position)


# Overridable.
func _get_laser_scene() -> PackedScene:
	return null


# Overridable.
func _move(_delta: float) -> void:
	global_position += _direction * speed


func _set_direction(new_value: _DirectionValues) -> void:
	direction = new_value
	if is_inside_tree():
		_update_direction()


# Overridable.
func _update_direction() -> void:
	match direction:
		_DirectionValues.RIGHT:
			_x_reset_value = 0.0
			_direction = Vector2.RIGHT
		_DirectionValues.LEFT:
			_x_reset_value = get_viewport().size.x
			_direction = Vector2.LEFT


# Overridable
func _screen_exited_handler() -> void:
	global_position.x = _x_reset_value


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_screen_exited_handler()

func _on_timer_shoot_timeout() -> void:
	_shoot()
