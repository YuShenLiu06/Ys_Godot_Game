# 追踪子弹最大生存时间提升牌包
class_name TrackingBulletMaxLifetimeCard
extends BaseCard

# 最大生存时间增加值
var max_lifetime_increase: float = 0.3

func _init():
	card_name = "追踪子弹最大生存时间提升"
	description = "追踪子弹最大生存时间+0.3"
	icon_path = ""
	
	# 设置标签
	card_tag = "tracking_bullet"  # 追踪子弹牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机增加值等
	# max_lifetime_increase = 0.3
	description = "追踪子弹最大生存时间+" + str(max_lifetime_increase)

func apply_effect() -> void:
	# 应用最大生存时间提升效果
	on_before_apply()
	
	# 发送信号到玩家
	SignalBus.Sel_Tracking_Bullet_Max_Lifetime.emit(max_lifetime_increase)
	
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