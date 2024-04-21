extends Node2D


signal stage_finished
signal enemy_died(score_value: int)

enum Stage {
	NO_STAGE,
	STAGE_01,
	STAGE_02,
	STAGE_03,
	STAGE_04,
	STAGE_05,
}

const StageScenes: Dictionary = {
	Stage.STAGE_01: preload("res://scenes/level_stages/level_stage_01.tscn"),
	Stage.STAGE_02: preload("res://scenes/level_stages/level_stage_02.tscn"),
	Stage.STAGE_03: preload("res://scenes/level_stages/level_stage_03.tscn"),
	Stage.STAGE_04: preload("res://scenes/level_stages/level_stage_04.tscn"),
	Stage.STAGE_05: preload("res://scenes/level_stages/level_stage_05.tscn"),
}

var _current_stage: Stage = Stage.NO_STAGE
var _total_enemies: int = 0
var _remaining_enemies: int = _total_enemies

@onready var energy_progress_bar = %EnergyProgressBar
@onready var score_label = %ScoreLabel


func _ready() -> void:
	LevelManager.set_current_level(self)


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func next_stage() -> void:
	if _current_stage == Stage.STAGE_05:
		_current_stage = Stage.STAGE_01
	else:
		_current_stage += 1
	_start_current_stage()


func restart_stage() -> void:
	_start_current_stage()


func _start_current_stage() -> void:
	var stage = StageScenes[_current_stage].instantiate()
	for child in $Enemies.get_children():
		child.queue_free()
	$Enemies.call_deferred("add_child", stage)
	_total_enemies = 0
	for enemy in stage.get_children():
		enemy.died.connect(_on_individual_enemy_died)
		_total_enemies += 1
	_remaining_enemies = _total_enemies


func _on_individual_enemy_died(score_value: int) -> void:
	enemy_died.emit(score_value)
	_remaining_enemies -= 1
	if _remaining_enemies <= 0:
		stage_finished.emit()
