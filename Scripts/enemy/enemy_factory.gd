class_name EnemyFactory
extends RefCounted

# 敌人工厂类 - 负责创建和管理敌人实例
# 遵循单例模式和工厂模式，确保敌人创建的一致性

# 所有敌人场景的静态数组
# 注意：这里使用具体类型违反了依赖倒置原则，但为了简化示例保持现状
enum EnemyType {
	SlimeNormal = 1,
	SlimeGiant = 2,
	BunnyNormal = 3,
}

static var _all_enemy_scenes: Array = [
	preload("res://Scenes/enemy/slime/normal_slime.tscn"), # 1
	preload("res://Scenes/enemy/slime/giant_slime.tscn"), # 2
	preload("res://Scenes/enemy/bunny/normal_bunny.tscn"), # 3
]

# 所有敌人实例的静态数组
static var _all_enemy_instances: Array = []


# 初始化所有敌人实例
static func initialize_enemy_instances():
	_all_enemy_instances.clear()
	for scene in _all_enemy_scenes:
		var enemy_instance = scene.instantiate()
		_all_enemy_instances.append(enemy_instance)

# 获取所有启用的敌人实例
# @return Array[Enemy_father] 启用的敌人数组
static func get_all_enabled_enemy() -> Array:
	var enabled_enemies: Array = []
	# 确保实例已初始化
	if _all_enemy_instances.is_empty():
		initialize_enemy_instances()
	
	for enemy in _all_enemy_instances:
		if enemy.is_enabled:
			enabled_enemies.append(enemy)
	return enabled_enemies

# 获取所有敌人实例（包括禁用的）
# @return Array[Enemy_father] 所有敌人数组
static func get_all_enemy() -> Array:
	# 确保实例已初始化
	if _all_enemy_instances.is_empty():
		initialize_enemy_instances()
	
	return _all_enemy_instances.duplicate() # 返回副本避免外部修改

# 根据权重来获取一个随机敌人场景
static func get_random_enemy_by_weight() -> PackedScene:
	var enabled_enemies: Array = get_all_enabled_enemy()
	
	# 错误处理：如果没有启用的敌人，返回null
	if enabled_enemies.is_empty():
		push_warning("没有可用的敌人实例！")
		return null
	
	var total_weight: int = 0
	for i in enabled_enemies:
		total_weight += i.enemy_weight
	
	# 错误处理：如果总权重为0，返回随机敌人场景
	if total_weight <= 0:
		push_warning("敌人总权重为0，返回随机敌人！")
		# 获取随机敌人的场景文件路径
		var random_enemy = enabled_enemies.pick_random()
		return get_scene_by_instance(random_enemy)
	
	var random_value: int = randi_range(1, total_weight)
	var current_weight: int = 0
	for enemy in enabled_enemies:
		current_weight += enemy.enemy_weight
		if random_value <= current_weight:
			# 返回对应的场景文件而不是实例
			return get_scene_by_instance(enemy)
	
	# 兜底返回（理论上不会执行到这里）
	return _all_enemy_scenes[0]

# 根据敌人实例获取对应的场景文件
# @param enemy_instance 敌人实例
# @return PackedScene 对应的场景文件
static func get_scene_by_instance(enemy_instance) -> PackedScene:
	for scene in _all_enemy_scenes:
		if scene.resource_path == enemy_instance.scene_file_path:
			return scene
	return null

# 根据敌人类型启用或禁用敌人
static func change_enemy_enabled_state(enemy_type: EnemyType, enabled: bool):
	# 敌人类型枚举值从1开始，数组索引从0开始，所以需要减1
	var index = enemy_type - 1
	if index >= 0 && index < _all_enemy_instances.size():
		_all_enemy_instances[index].is_enabled = enabled
	else:
		push_error("无效的敌人类型: " + str(enemy_type))