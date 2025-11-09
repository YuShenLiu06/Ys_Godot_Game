# 子弹伤害提升牌包
class_name BulletDamageCard
extends BaseCard

# 伤害系数
var damage_coefficient: float = 1.5

func _init():
	card_name = "子弹伤害提升"
	description = "子弹伤害*1.5"
	icon_path = ""
	
	# 设置标签
	card_tag = "basic"  # 基础牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	damage_coefficient = 1.5
	description = "子弹伤害*" + str(damage_coefficient)

func apply_effect() -> void:
	# 应用伤害提升效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Bullet_damage.emit(damage_coefficient)
	
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