extends Area2D


@export var direction: Vector2 = Vector2.DOWN
@export var speed: float = 10.0


func _ready() -> void:
	#rotation = global_position.angle_to(direction)
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	global_position += direction * speed
	look_at(global_position + direction)
	rotate(PI / 2.0)


func _on_hitting_player() -> void:
	print("Player has been hit")
	queue_free()


func _on_hitting_enemy(enemy: Node2D) -> void:
	enemy.die()
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	_on_hitting_player()


func _on_area_entered(area: Area2D) -> void:
	_on_hitting_enemy(area.get_parent())
