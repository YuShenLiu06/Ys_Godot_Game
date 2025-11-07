extends Area2D

@export var explosion_scale : float = 1.0

func _deug():
	print("[debug] Bullet explosion instantiated")
	print("[debug] Explosion scale: ", explosion_scale)

func _ready() -> void:
	#等待0.42后删除自己(12fps下5帧)
	clear_itself(0.42)
	# _deug()
	set_explosion_scale(explosion_scale)

func _process(delta: float) -> void:
	pass

#对于本身缩放的控制
func set_explosion_scale(scale: float) -> void:
	# print("[debug] Setting explosion scale to: ", scale)
	$".".scale = Vector2(scale,scale)

func clear_itself(wait_time: float):
	await get_tree().create_timer(wait_time).timeout
	queue_free()