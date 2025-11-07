extends Camera2D
class_name ScreenShake

# 屏幕抖动效果实现
# 这个脚本为Camera2D添加了屏幕抖动功能，常用于爆炸、受击等场景增强视觉冲击力

# 抖动参数 - 可在编辑器中调整
@export var shake_strength: float = 5.0  # 抖动强度：控制抖动的最大偏移距离（像素）
@export var shake_duration: float = 0.3  # 抖动持续时间：抖动效果持续的总时间（秒）
@export var shake_decay: float = 1.0     # 抖动衰减速度：控制抖动强度随时间衰减的速度

# 内部变量 - 运行时使用
var is_shaking: bool = false              # 抖动状态标志：true表示正在抖动
var current_shake_strength: float = 0.0  # 当前帧的抖动强度：随时间衰减
var shake_time_left: float = 0.0          # 剩余抖动时间：用于计算衰减
var original_offset: Vector2              # 相机原始偏移：抖动结束后恢复到此位置

func _ready() -> void:
	# 初始化时保存相机的原始偏移量
	original_offset = offset #offeset 是Camera2D的属性，表示相机的偏移位置

func _physics_process(delta: float) -> void:
	# 每帧检查是否需要处理抖动效果
	if is_shaking:
		# 根据delta时间和衰减速度减少剩余抖动时间
		shake_time_left -= delta * shake_decay
		
		if shake_time_left <= 0:
			# 抖动时间结束，恢复原始位置并停止抖动
			is_shaking = false
			offset = original_offset
		else:
			# 计算当前帧的抖动强度（线性衰减）
			# 强度随剩余时间比例从最大值衰减到0
			current_shake_strength = shake_strength * (shake_time_left / shake_duration)
			
			# 生成随机偏移量，模拟抖动效果
			# 使用randf_range在当前强度范围内生成随机偏移
			var random_offset = Vector2(
				randf_range(-current_shake_strength, current_shake_strength),
				randf_range(-current_shake_strength, current_shake_strength)
			)
			# 将随机偏移应用到相机
			offset = original_offset + random_offset

# 开始屏幕抖动效果
# 参数：
#   strength: 抖动强度（可选，默认使用预设值）
#   duration: 抖动持续时间（可选，默认使用预设值）
func start_shake(strength: float = 0.0, duration: float = 0.0):
	# 如果提供了强度参数，则覆盖默认值
	if strength > 0:
		shake_strength = strength
	# 如果提供了持续时间参数，则覆盖默认值
	if duration > 0:
		shake_duration = duration
	
	# 初始化抖动状态
	shake_time_left = shake_duration
	is_shaking = true

# 立即停止屏幕抖动效果
# 用于强制停止抖动，恢复相机原始位置
func stop_shake():
	is_shaking = false
	offset = original_offset