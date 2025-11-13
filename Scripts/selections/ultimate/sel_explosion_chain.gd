class_name SelExplosionChain
extends BaseCard


func _init():
	card_name = "选择爆炸连锁"
	description = "选择爆炸连锁"
	icon_path = ""
	
	# 设置标签
	card_tag = "ultimate"  # 爆炸连锁牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	description = "启用/强化爆炸连锁"

func apply_effect() -> void:
	# 应用爆炸连锁效果
	on_before_apply()
	
	# 发送信号到敌人
	SignalBus.Sel_Explosion_Chain.emit()

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