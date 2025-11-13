# 爆炸连锁伤害系数提升牌包
class_name ExplosionChainDamageCard
extends BaseCard

# 伤害系数
var damage_coefficient: float = 1.25

func _init():
	card_name = "爆炸连锁伤害系数提升"
	description = "爆炸连锁伤害系数*1.25"
	icon_path = ""
	
	# 设置标签
	card_tag = "explosion_chain"  # 爆炸连锁牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	description = "爆炸连锁伤害系数*" + str(damage_coefficient)

func apply_effect() -> void:
	# 应用伤害系数提升效果
	on_before_apply()
	
	# 发送信号到敌人
	SignalBus.Sel_Explosion_Chain_Damage.emit(damage_coefficient)
	
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