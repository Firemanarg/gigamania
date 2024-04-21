extends "res://scenes/enemies/enemy.gd"


enum _Mode {
	MOVING,
	AIMING,
	ATTACKING,
}


func _physics_process(_delta: float) -> void:
	_draw_shoot_line()


func _draw_shoot_line() -> void:
	for line in $AimingLines.get_children():
		line.queue_free()
	var player_position: Vector2 = LevelManager.player.global_position
	var player_direction: Vector2 = (
		global_position.direction_to(player_position)
	)
	var screen_size: Vector2 = get_viewport().size
	var line: Line2D = Line2D.new()
	var point: Vector2 = Vector2(0, 0)
	var shoot_direction: Vector2 = player_direction
	for i in 3:
		line.add_point(point)
		point += shoot_direction * (global_position + point).distance_squared_to(screen_size)
		const test_offset_length: float = 1.0
		var test_point: Vector2 = point + shoot_direction * test_offset_length
		if test_point.y < 0.0 or test_point.y > screen_size.y:
			shoot_direction.y *= -1
		if test_point.x < 0.0 or test_point.x > screen_size.x:
			shoot_direction.x *= -1

	$AimingLines.add_child(line)


func _calculate_next_point(
	current_point: Vector2, shoot_direction: Vector2, screen_size: Vector2
) -> Vector2:
	var current_point_global_position: Vector2 = current_point + global_position
	var next_point: Vector2 = current_point_global_position + shoot_direction * 1000
	next_point.clamp(Vector2(0, 0), screen_size)
	return (next_point - global_position)
