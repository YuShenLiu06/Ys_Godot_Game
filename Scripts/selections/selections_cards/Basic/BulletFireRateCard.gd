# 开火速率提升牌包
class_name BulletFireRateCard
extends BaseCard

# 开火速率系数
var fire_rate_coefficient: float = 0.75

func _init():
	card_name = "开火速率提升"
	description = "开火时间*0.75"
	icon_path = ""
	
	# 设置标签
	card_tag = "basic"  # 基础牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	fire_rate_coefficient = 0.75
	description = "开火时间*" + str(fire_rate_coefficient)

func apply_effect() -> void:
	# 应用开火速率提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Bullet_fire_timer.emit(fire_rate_coefficient)
	
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