extends Control


const LevelScene: PackedScene = preload("res://scenes/level.tscn")
const MainMenuScene: PackedScene = preload("res://scenes/screens/main_menu_screen.tscn")

@onready var score_label: Label = %ScoreLabel
@onready var name_line_edit: LineEdit = %NameLineEdit


func _ready() -> void:
	score_label.text = str(LevelManager.get_score())


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_packed(LevelScene)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(MainMenuScene)
