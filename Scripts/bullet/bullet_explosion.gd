extends Area2D

@export var explosion_scale : float = 1.0
var Bullet_damage : float =1.0

func _deug():
	print("[debug] Bullet explosion instantiated")
	print("[debug] Explosion scale: ", explosion_scale)

func _ready() -> void:
	#屏幕震动
	#根据Bullet_damage计算震动强度
	# var Vibration_intensityzheng : float = Bullet_damage
	if get_tree().current_scene.has_method("screen_shake"):
		get_tree().current_scene.screen_shake(1.0, 0.4)
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