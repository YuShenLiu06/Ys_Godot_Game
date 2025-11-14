class_name PenetrateDamageCard
extends BaseCard

var damage_coefficient: float = 1.2

func _init():
	card_name = "穿透伤害强化"
	description = "提升穿透伤害系数"
	icon_path = ""
	
	# 设置标签
	card_tag = "penetrate"  # 穿透牌包

func initialize() -> void:
	# 初始化牌包，设置随机系数
	description = "穿透伤害系数*" + str(damage_coefficient) + "倍"
	# 存储系数供apply_effect使用


func apply_effect() -> void:
	# 应用穿透伤害提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Penetrate_Damage_Cof.emit(damage_coefficient)

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