# 子弹伤害提升牌包
class_name ReinTrue
extends BaseCard

# 伤害系数

func _init():
	card_name = "选择轮回"
	description = "选择轮回但是保留终极效果"
	icon_path = ""
	
	# 设置标签
	card_tag = "Rein" # 轮回卡包

func initialize() -> void:

	description = "选择轮回但是保留终极效果"
	is_enabled = false
	
func apply_effect() -> void:
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Rein.emit()
	print("轮回选择：是")
	
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