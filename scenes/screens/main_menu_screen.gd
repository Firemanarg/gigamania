extends Control


const LevelScene: PackedScene = preload("res://scenes/level.tscn")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(LevelScene)
