extends CharacterBody2D


const MaxRotationAngle: float = deg_to_rad(15)
const RotationStep: float = deg_to_rad(0.5)
const DefaultNormalSpeed: float = 400.0
const DefaultTurboSpeed: float = 2 * DefaultNormalSpeed
const LaserScene: PackedScene = preload("res://scenes/lasers/laser_player.tscn")

@export var normal_speed: float = DefaultNormalSpeed
@export var turbo_speed: float = DefaultTurboSpeed
@export var rotation_speed: float = 10.0
@export var shoot_delay: float = 1.0

var _speed: float = DefaultNormalSpeed
var _is_turbo_enabled: bool = false

@onready var timer_shoot = get_node("TimerShoot")


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	_turbo()
	_move(delta)
	_handle_shoot()


func _handle_shoot() -> void:
	if not timer_shoot.is_stopped():
		return
	var is_shooting: bool = Input.is_action_pressed("shoot")
	if is_shooting:
		_shoot()
		timer_shoot.start(shoot_delay)


func _shoot() -> void:
	var laser: Area2D = LaserScene.instantiate()
	laser.direction = Vector2.UP
	LevelManager.add_laser(laser, global_position)


func _turbo() -> void:
	_is_turbo_enabled = Input.is_action_pressed("turbo")
	if _is_turbo_enabled:
		_speed = turbo_speed
	else:
		_speed = normal_speed


func _move(delta: float) -> void:
	var direction_x: float = Input.get_axis("move_left", "move_right")
	velocity.x = lerp(velocity.x, direction_x * _speed, 0.5)
	rotation = lerp(rotation, RotationStep * rotation_speed * velocity.x * delta, 0.5)
	rotation = clamp(rotation, -MaxRotationAngle, MaxRotationAngle)
	move_and_slide()
