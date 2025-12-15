# 移动射击觉醒卡包
class_name AwakenMovingShooting
extends BaseCard

var is_use : bool = false

func _init():
	card_name = "移动射击觉醒"
	description = "移动射击"
	icon_path = ""
	
	# 设置标签
	card_tag = "Awaken"  # 觉醒牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	description = "移动射击"
	is_enabled = false

func apply_effect() -> void:
	# 应用移动射击效果
	on_before_apply()
	
	# 发送信号到玩家
	SignalBus.Sel_Moving_Shooting.emit()
	is_use = true
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
	if !is_use:
		is_enabled = true