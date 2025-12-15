# 开火速率提升牌包
class_name AwakenEmpty
extends BaseCard

# 开火速率系数

func _init():
	card_name = "AwakenEmpty"
	description = "你已经添加了所有的觉醒"
	icon_path = ""
	
	# 设置标签
	card_tag = "basic_card"  # 基础牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	description = "你已经添加了所有的觉醒"
	is_enabled = false

func apply_effect() -> void:
	# 应用开火速率提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	on_after_apply()

func can_apply() -> bool:
	# 检查是否可以应用此牌包
	return true

func on_before_apply() -> void:
	# 应用前的效果，如播放音效等
	pass

func on_after_apply() -> void:
	# 应用后的效果，如播放特效等
	pass
func Close_Choose_time() -> void:
	# 关闭选择界面时的处理（如果需要）
	is_enabled = true