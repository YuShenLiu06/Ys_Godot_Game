extends Area2D

@export var bullet_speed : float = 300
@export var face_derection : int = 1
@export var Damage : float = 1
@export var max_angle : float =10.0  # 最大角度限制（度）
@export var node_player : Node2D # 连接到玩家节点

var current_direction : Vector2 = Vector2.RIGHT  # 当前移动方向

func _ready() -> void:
	# 设置初始方向朝向鼠标位置
	set_direction_to_mouse(max_angle)
	
	await get_tree().create_timer(3).timeout
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	position += current_direction * bullet_speed * delta

func set_direction_to_mouse(cone: float) -> void:
	# 如果没有玩家节点，使用默认方向
	if not node_player:
		current_direction = Vector2(face_derection, 0)
		rotation = current_direction.angle()
		return
	
	# 获取鼠标位置
	var mouse_position = get_global_mouse_position()
	
	# 获取玩家朝向作为基准方向
	var player_direction = Vector2.RIGHT
	if node_player and "Face_direction" in node_player:
		player_direction = Vector2(node_player.Face_direction, 0)
	
	# 计算鼠标相对于玩家位置的方向
	var mouse_direction = (mouse_position - node_player.global_position).normalized()
	
	# 计算鼠标方向相对于玩家朝向的夹角
	var angle_to_mouse = player_direction.angle_to(mouse_direction)
	
	# 将锥形角度减半，用于左右两侧限制
	cone /= 2
	
	# 限制角度在锥形范围内，并转换为方向向量
	var clamped_angle = clamp(rad_to_deg(angle_to_mouse), -cone, cone)
	current_direction = player_direction.rotated(deg_to_rad(clamped_angle)).normalized()
	
	# 更新子弹朝向
	rotation = current_direction.angle()

func get_bullet_type() -> String:
	return "normal_bullet"
