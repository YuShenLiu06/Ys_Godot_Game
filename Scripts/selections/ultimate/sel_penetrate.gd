class_name SelPenetrate
extends BaseCard


func _init():
	card_name = "选择终极穿透"
	description = "选择终极穿透"
	icon_path = ""
	
	# 设置标签
	card_tag = "ultimate"  # 终极穿透牌包

func initialize() -> void:
	# 初始化牌包，可以在这里设置随机系数等
	description = "启用/强化终极穿透"

func apply_effect() -> void:
	# 应用终极穿透效果
	on_before_apply()
	
	# 发送信号到游戏管理器
	SignalBus.Sel_Penetrate.emit()

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