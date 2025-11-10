# 追踪子弹转向速度提升牌包
class_name TrackingBulletTurnSpeedCard
extends BaseCard

# 转向速度系数
var turn_speed_coefficient: float = 1.25

func _init():
	card_name = "追踪子弹转向速度提升"
	description = "追踪子弹转向速度*1.2"
	icon_path = ""
	
	# 设置标签
	card_tag = "tracking_bullet"  # 追踪子弹牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	# turn_speed_coefficient = 1.1
	description = "追踪子弹转向速度*" + str(turn_speed_coefficient)

func apply_effect() -> void:
	# 应用转向速度提升效果
	on_before_apply()
	
	# 发送信号到玩家
	SignalBus.Sel_Tracking_Bullet_Turn_Speed.emit(turn_speed_coefficient)
	
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