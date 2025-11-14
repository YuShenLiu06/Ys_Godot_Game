extends Area2D

@export var explosion_scale: float = 1.0
var Bullet_damage: float = 1.0
var explosion_damage: float = 2.0  # 爆炸阈值伤害，默认值与enemy.gd中的默认值一致
var cof_base: float = 1.1
var cof_Denominator: int = 3

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
	set_explosion_scale(calculate_explosion_scale(cof_base, cof_Denominator))

func _process(delta: float) -> void:
	pass

#对于本身缩放的控制
func set_explosion_scale(scale: float) -> void:
	# print("[debug] Setting explosion scale to: ", scale)
	$".".scale = Vector2(scale, scale)

func clear_itself(wait_time: float):
	await get_tree().create_timer(wait_time).timeout
	call_deferred("queue_free")

func get_bullet_type() -> String:
	return "bullet_explosino"

func calculate_explosion_scale(cof_base: float, cof_Denominator: int) -> float: # 可以调整底数和分母系数用来调整爆炸的增炸速度
	return clamp(cof_base ** (1 + (Bullet_damage - explosion_damage) / cof_Denominator), 1.0, 3.0) # 根据伤害调整爆炸范围，限制在5到20之间

