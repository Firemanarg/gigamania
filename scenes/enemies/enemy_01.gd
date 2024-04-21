extends "res://scenes/enemies/enemy.gd"


func _get_laser_scene() -> PackedScene:
	const laser_scene: PackedScene = preload("res://scenes/lasers/laser_enemy_01.tscn")
	return laser_scene


func _shoot() -> void:
	var laser: Area2D = _get_laser_scene().instantiate()
	laser.direction = Vector2.DOWN
	laser.speed = projectile_speed
	LevelManager.add_laser(laser, global_position)
