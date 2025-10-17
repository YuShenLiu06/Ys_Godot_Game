extends Area2D

@export var bullet_speed : float = 100
@export var face_derection : int = 1
@export var Damage : float = 1

#signal Change_damage(New_damage)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(bullet_speed*face_derection,0) * delta
	#face_derection=get_node("player").get_player_derection()


	#emit_signal("Change_damage",Set_damage)
	
