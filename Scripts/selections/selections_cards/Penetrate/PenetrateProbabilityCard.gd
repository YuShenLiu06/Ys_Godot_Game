class_name PenetrateProbabilityCard
extends BaseCard

var probability_coefficient: float = 0.05

func _init():
	card_name = "穿透概率强化"
	description = "提升穿透触发概率"
	icon_path = ""
	
	# 设置标签
	card_tag = "penetrate"  # 穿透牌包

func initialize() -> void:
	# 初始化牌包，设置随机系数
	description = "穿透概率+" + str(probability_coefficient)
	# 存储概率提升值供apply_effect使用

# 存储概率提升值

func apply_effect() -> void:
	# 应用穿透概率提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Penetrate_Probability.emit(probability_coefficient)

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