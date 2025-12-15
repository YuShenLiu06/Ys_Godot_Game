extends Enemy_father
class_name Giant_slime

func _init() -> void:
	# 子类特有的初始化（父类的 _ready 会在节点加入场景后调用 _init）
	injured_wait_time = 0.5
	Health = 8
	Enemy_speed = 10
	enemy_weight = 1
	Exp = 15
	is_enabled = false
	lifetime = 50

func get_health() -> float:
	return Health

func set_health(new_health: float) -> void:
	Health = new_health