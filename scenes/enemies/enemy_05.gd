extends "res://scenes/enemies/enemy.gd"


@export_group("Movement")
@export var movement_radius: float = 200.0
@export var rotation_speed: float = 5.0
@export_range(-1.0, 1.0, 0.01) var initial_phase: float = 0.0

var _elapsed_time: float = 0.0
var _x_offset: float = 0.0

@onready var _original_postition: Vector2 = global_position


func _initial_setup() -> void:
	_x_offset = global_position.x


func _get_laser_scene() -> PackedScene:
	const laser_scene: PackedScene = preload("res://scenes/lasers/laser_enemy_05.tscn")
	return laser_scene


func _shoot() -> void:
	print("Shooting")
	var laser: Area2D = _get_laser_scene().instantiate()
	laser.direction = Vector2.DOWN
	laser.speed = projectile_speed
	LevelManager.add_laser(laser, global_position)


func _move(delta: float) -> void:
	var movement: Vector2 = Vector2(
		cos(_elapsed_time * rotation_speed + initial_phase * rotation_speed),
		sin(_elapsed_time * rotation_speed + initial_phase * rotation_speed)
	) * movement_radius
	rotation = movement.angle() + (3.0 * PI / 4.0)
	global_position = Vector2(_x_offset, _original_postition.y) + movement
	_elapsed_time += delta
	_x_offset += speed
	if _x_offset > get_viewport().size.x + movement_radius:
		_x_offset = 0.0
		_elapsed_time = 0.0
		initial_phase = 1.0


func _screen_exited_handler() -> void:
	pass

