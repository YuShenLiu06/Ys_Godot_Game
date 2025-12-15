# 子弹伤害提升牌包
class_name ReinFalse
extends BaseCard

# 伤害系数

func _init():
	card_name = "拒绝轮回"
	description = "继续当前游戏不进行轮回"
	icon_path = ""
	
	# 设置标签
	card_tag = "Rein" # 轮回卡包

func initialize() -> void:

	description = "继续当前游戏不进行轮回"
	
func apply_effect() -> void:
	on_before_apply()
	
	# 发送信号到游戏管理器
	# SignalBus.Sel_Rein.emit()
	
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