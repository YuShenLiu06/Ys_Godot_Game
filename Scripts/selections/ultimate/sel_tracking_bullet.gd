class_name SelTrackingBullet
extends BaseCard


func _init():
	card_name = "选择追踪子弹"
	description = "选择追踪子弹"
	icon_path = ""
	
	# 设置标签
	card_tag = "ultimate"  # 追踪子弹牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	# turn_speed_coefficient = 1.1
	description = "终极技能:启用/强化追踪子弹"

func apply_effect() -> void:
	# 应用转向速度提升效果
	on_before_apply()
	
	# 发送信号到玩家
	SignalBus.Sel_Tracking_Bullet.emit()

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