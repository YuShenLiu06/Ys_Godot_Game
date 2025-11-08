extends Enemy_father

func _init() -> void:
	# 子类特有的初始化（父类的 _ready 会在节点加入场景后调用 _init）
	injured_wait_time = 0.5
	Health = 1.5
	Enemy_speed = 30

func get_health() -> float:
	return Health

func set_health(new_health: float) -> void:
	Health = new_health