# 经验获取提升牌包
class_name ExpGainCard
extends BaseCard

# 经验系数
var exp_coefficient: float = 2.0

func _init():
	card_name = "经验获取提升"
	description = "经验获取*2"
	icon_path = ""
	
	# 设置标签
	card_tag = "basic"  # 基础牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	exp_coefficient = 2.0
	description = "经验获取*" + str(exp_coefficient)

func apply_effect() -> void:
	# 应用经验获取提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Exp_obtain.emit(exp_coefficient)
	
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