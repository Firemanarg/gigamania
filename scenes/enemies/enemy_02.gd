extends "res://scenes/enemies/enemy.gd"


@export_group("Movement")
@export var frequency: float = 5.0
@export var amplitude: float = 50.0

var _time: float = 0.0
var _reference_y: float = 0.0


func _initial_setup() -> void:
	_reference_y = global_position.y


func _get_laser_scene() -> PackedScene:
	const laser_scene: PackedScene = preload("res://scenes/lasers/laser_enemy_02.tscn")
	return laser_scene


func _update_direction() -> void:
	match direction:
		_DirectionValues.RIGHT:
			_x_reset_value = 0.0
			_direction = Vector2.RIGHT
			$Sprite2D.scale.x = -$Sprite2D.scale.x
		_DirectionValues.LEFT:
			_x_reset_value = get_viewport().size.x
			_direction = Vector2.LEFT
			$Sprite2D.scale.x = abs($Sprite2D.scale.x)


func _move(delta: float) -> void:
	global_position += _direction * speed
	global_position.y = _reference_y + sin(_time * frequency) * amplitude
	_time += delta


func _shoot() -> void:
	var laser = _get_laser_scene().instantiate()
	laser.speed = projectile_speed
	LevelManager.add_laser(laser, global_position)
	laser.direction = global_position.direction_to(LevelManager.player.global_position)
