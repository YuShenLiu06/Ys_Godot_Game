extends Area2D
class_name TrackingBullet

# 追踪子弹核心参数
@export var bullet_speed : float = 200
@export var Damage : float = 1
@export var turn_speed : float = 3.0  # 转向速度，值越大转向越快
@export var max_lifetime : float = 2.0  # 最大生存时间
@export var target_search_interval : float = 0.1  # 目标搜索间隔
@export var node_player : Node2D #连接到玩家节点

# 内部状态变量
var current_direction : Vector2 = Vector2.RIGHT  # 当前移动方向
var target : Node2D = null  # 当前追踪目标
var time_elapsed : float = 0.0  # 生存时间计时器
var target_search_timer : float = 0.1  # 目标搜索计时器

func _ready() -> void:
	# 添加到Bullet组，保持与原子弹系统的兼容性
	add_to_group("Bullet")
	
	# 连接信号
	# body_entered.connect(_on_body_entered)
	
	# 设置初始方向（基于玩家朝向）
	set_initial_direction()

	#查找目标（160°范围内）
	find_nearest_enemy_in_cone()


func _physics_process(delta: float) -> void:
	# 更新计时器
	time_elapsed += delta
	target_search_timer += delta
	
	# 检查生存时间
	if time_elapsed >= max_lifetime:
		queue_free()
		return
	
	# 判断是否存活
	if target_search_timer >= target_search_interval:
		target_search_timer = 0.0
		if judge_is_enemy_dead():
				find_nearest_enemy()
	
	# 更新移动方向和位置
	update_movement(delta)

func set_initial_direction() -> void:
	# 从玩家获取初始朝向
	if node_player:
		current_direction = Vector2(node_player.Face_direction, 0)

func find_nearest_enemy_in_cone() -> void:
	# 获取所有敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		target = null
		return
	
	# 找到90°范围内的最近敌人
	var nearest_enemy : Node2D = null
	var min_distance : float = INF
	var cone_angle = deg_to_rad(45.0)  #45*2=90度锥形范围
	
	for enemy in enemies:
		# 检查敌人是否存活
		if enemy.is_dead:
			continue
			
		# 计算敌人相对于子弹当前位置的方向
		var enemy_direction = (enemy.global_position - global_position).normalized()
		
		# 计算敌人方向与当前方向的夹角
		var angle_to_enemy = current_direction.angle_to(enemy_direction)
		
		# 检查敌人是否在120°范围内
		if abs(angle_to_enemy) > cone_angle:
			continue
			
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	
	target = nearest_enemy

func find_nearest_enemy() -> void:
	# 获取所有敌人
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		target = null
		return
	
	# 找到最近的敌人
	var nearest_enemy : Node2D = null
	var min_distance : float = INF
	
	for enemy in enemies:
		# 检查敌人是否存活
		if enemy.is_dead:
			continue
			
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_enemy = enemy
	
	target = nearest_enemy

func update_movement(delta: float) -> void:
	var target_direction = current_direction
	
	# 如果有目标，计算面向目标的方向
	if target and is_instance_valid(target):
		target_direction = (target.global_position - global_position).normalized()
	
	# 平滑转向到目标方向
	current_direction = current_direction.lerp(target_direction, turn_speed * delta).normalized()
	
	# 移动子弹
	position += current_direction * bullet_speed * delta
	
	# 更新子弹朝向
	update_bullet_rotation()

func update_bullet_rotation() -> void:
	# 根据移动方向旋转子弹精灵
	var angle = current_direction.angle()
	rotation = angle

# 获取当前速度（用于其他系统调用）
func get_velocity() -> Vector2:
	return current_direction * bullet_speed

# 边界碰撞检测
# func _on_body_entered(body: Node2D) -> void:
# 	# 检查是否碰到边界（StaticBody2D且父节点是Boundary）
# 	if body is StaticBody2D and body.get_parent() and body.get_parent().name == "Boundary":
# 		queue_free()

func judge_is_enemy_dead() -> bool:
	if target == null:
		return true
	if target.is_dead:
		return true
	return false

func get_bullet_type() -> String:
	return "tracking_bullet"