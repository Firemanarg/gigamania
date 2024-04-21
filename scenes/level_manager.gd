extends Node


var current_level: Node2D = null
var laser_layer: Node2D = null
var player: Node2D = null

var _stage_max_time: float = 100.0
var _max_player_energy: float = 100.0
var _player_energy: float = _max_player_energy
var _player_energy_drain_amount: float = _calculate_player_energy_drain_amount()

var _total_score: int = 0
var _stage_score: int = 0

@onready var _timer_energy_drain: Timer = Timer.new()


func _ready() -> void:
	add_child(_timer_energy_drain)
	_timer_energy_drain.timeout.connect(_on_timer_energy_drain_timeout)
	_timer_energy_drain.start(1.0)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func add_laser(laser: Node2D, global_position: Vector2) -> void:
	if laser == null:
		print("Laser scene is null!")
		return
	laser_layer.add_child(laser)
	laser.global_position = global_position


func set_current_level(level: Node2D) -> void:
	if level == null:
		print("Attempting to assign a null level")
		return
	current_level = level
	laser_layer = current_level.get_node("LaserLayer")
	player = current_level.get_node("Player")
	current_level.energy_progress_bar.min_value = 0.0
	current_level.energy_progress_bar.max_value = _max_player_energy
	current_level.energy_progress_bar.set_value(_max_player_energy)
	current_level.enemy_died.connect(_on_enemy_died)
	current_level.stage_finished.connect(_on_stage_finished)
	current_level.next_stage()


func _update_energy_progress_bar() -> void:
	if current_level == null:
		return
	current_level.energy_progress_bar.set_value(_player_energy)


func _update_score_label() -> void:
	if current_level == null:
		return
	current_level.score_label.text = str(_total_score + _stage_score)


func _calculate_player_energy_drain_amount() -> float:
	if is_zero_approx(_stage_max_time):
		return 0.0
	return (_max_player_energy / _stage_max_time)


func _on_timer_energy_drain_timeout() -> void:
	_player_energy -= _player_energy_drain_amount
	_update_energy_progress_bar()
	_timer_energy_drain.start(1.0)


func _on_enemy_died(score_value: int) -> void:
	_stage_score += score_value
	_update_score_label()


func _on_stage_finished() -> void:
	_total_score += _stage_score
	_stage_score = 0
	current_level.next_stage()
