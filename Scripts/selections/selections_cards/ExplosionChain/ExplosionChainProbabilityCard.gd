# 爆炸连锁概率提升牌包
class_name ExplosionChainProbabilityCard
extends BaseCard

# 概率增加值
var probability_increase: float = 0.05

func _init():
	card_name = "爆炸连锁概率提升"
	description = "爆炸连锁概率+0.05"
	icon_path = ""
	
	# 设置标签
	card_tag = "explosion_chain"  # 爆炸连锁牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机增加值等
	description = "爆炸连锁概率*+" + str(probability_increase)

func apply_effect() -> void:
	# 应用概率提升效果
	on_before_apply()
	
	# 发送信号到敌人
	SignalBus.Sel_Explosion_Chain_Probability.emit(probability_increase)
	
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