extends Area2D

@export var bullet_speed : float = 300
@export var face_derection : int = 1
@export var Damage : float = 1

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	position += Vector2(bullet_speed*face_derection,0) * delta

func get_bullet_type() -> String:
	return "normal_bullet"
