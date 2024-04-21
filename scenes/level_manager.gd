extends Node


enum EnergyState {
	DRAINING,
	SCORING,
	RECHARGING,
}

const ScoringMultiplier: float = 20.0
const RechargingMultiplier: float = 40.0
const ScoreScreenScene: PackedScene = preload("res://scenes/screens/score_screen.tscn")

var current_level: Node2D = null
var laser_layer: Node2D = null
var player: Node2D = null

var stage_change_delay: float = 0.5
var stage_initial_delay: float = 2.0

var _stage_max_time: float = 60.0
var _max_player_energy: float = 100.0
var _player_energy: float = _max_player_energy

var _total_score: int = 0
var _stage_score: int = 0
var _lifes: int = 3

var _energy_state: EnergyState = EnergyState.DRAINING


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if current_level:
		_energy_handler(delta)
		_update_energy_progress_bar()
		_update_score_label()


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
	reset_all()
	laser_layer = current_level.get_node("LaserLayer")
	player = current_level.get_node("Player")
	current_level.energy_progress_bar.min_value = 0.0
	current_level.energy_progress_bar.max_value = _max_player_energy
	current_level.energy_progress_bar.set_value(_max_player_energy)
	current_level.enemy_died.connect(_on_enemy_died)
	current_level.stage_finished.connect(_on_stage_finished)
	await get_tree().create_timer(stage_change_delay).timeout
	current_level.next_stage()


func hit_player() -> void:
	player.global_position = player.start_position
	current_level.restart_stage()
	_stage_score = 0
	_lifes -= 1
	if _lifes <= 0:
		_go_to_score_screen()
		return
	current_level.set_life_icon_visibility(_lifes, false)


func reset_all() -> void:
	_total_score = 0
	_stage_score = 0
	_lifes = 3
	_player_energy = _max_player_energy


func get_score() -> int:
	return _total_score


func _energy_handler(delta) -> void:
	match _energy_state:
		EnergyState.DRAINING: _energy_draining_state(delta)
		EnergyState.SCORING: _energy_scoring_state(delta)
		EnergyState.RECHARGING: _energy_recharging_state(delta)


func _energy_draining_state(delta: float) -> void:
	var drain_amount: float = _get_player_energy_drain_amount() * delta
	_player_energy -= drain_amount
	if _player_energy <= 0:
		_go_to_score_screen()


func _energy_scoring_state(delta: float) -> void:
	var drain_amount: float = ScoringMultiplier * _get_player_energy_drain_amount() * delta
	_player_energy -= drain_amount
	_total_score += roundi(drain_amount * 20)
	if _player_energy <= 0:
		_energy_state = EnergyState.RECHARGING


func _energy_recharging_state(delta: float) -> void:
	var recharge_amount: float = RechargingMultiplier * _get_player_energy_drain_amount() * delta
	_player_energy += recharge_amount
	if _player_energy >= _max_player_energy:
		_player_energy = _max_player_energy
		current_level.next_stage()
		_energy_state = EnergyState.DRAINING


func _go_to_score_screen() -> void:
	get_tree().call_deferred("change_scene_to_packed", ScoreScreenScene)
	current_level = null
	laser_layer = null
	player = null


func _update_energy_progress_bar() -> void:
	if current_level == null:
		return
	current_level.energy_progress_bar.set_value(_player_energy)


func _update_score_label() -> void:
	if current_level == null:
		return
	current_level.score_label.text = str(_total_score + _stage_score)


func _get_player_energy_drain_amount() -> float:
	if is_zero_approx(_stage_max_time):
		return 0.0
	var turbo_multiplier: float = 1.0
	if not player == null:
		turbo_multiplier += int(player.is_turbo_enabled())
	return (_max_player_energy / _stage_max_time) * turbo_multiplier


func _on_enemy_died(score_value: int) -> void:
	_stage_score += score_value


func _on_stage_finished() -> void:
	_total_score += _stage_score
	_stage_score = 0
	_energy_state = EnergyState.SCORING
