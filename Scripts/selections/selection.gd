# 牌包选择主程序 - 负责牌包的创建、管理和UI交互
# 遵循单一职责原则，只负责牌包的UI交互和生命周期管理
extends Node2D

# 当前牌包实例
var current_card: BaseCard

# UI节点引用
@export var label: Label
@export var texture_button: TextureButton


func _ready() -> void:
	# 获取UI节点引用
	texture_button = $TextureButton
	label = $Label
	
	# 设置UI音效
	VolumeManager.setup_ui_sounds(self)
	
	# 信号链接
	SignalBus.Close_Choose_time.connect(clear)

# 初始化牌包
func initialize_card(card: BaseCard) -> void:
	current_card = card
	
	# 初始化牌包
	if current_card:
		current_card.initialize()
		
		# 更新UI显示
		update_ui_display()

# 更新UI显示
func update_ui_display() -> void:
	if current_card and label:
		label.text = current_card.get_display_text()

# 按钮被按下时调用
func _on_button_pressed() -> void:
	if current_card and current_card.can_apply():
		# 应用牌包效果
		current_card.apply_effect()
		
		# 发送关闭选择界面信号
		SignalBus.Close_Choose_time.emit()

# 清理牌包
func clear():
	queue_free()

# 设置牌包位置（用于布局）
func set_card_position(pos: Vector2) -> void:
	position = pos

# 便捷方法：通过牌包类型初始化（已弃用，使用标签系统替代）
func initialize_by_type(card_type) -> void:
	push_warning("initialize_by_type 已弃用，请使用基于标签的方法")
	# 回退到随机初始化
	initialize_random()

# 便捷方法：通过标签初始化
func initialize_by_tag(tag: String) -> void:
	var card = CardFactory.create_card_by_tag(tag)
	initialize_card(card)

# 便捷方法：随机初始化
func initialize_random() -> void:
	var card = CardFactory.create_random_enabled_card()
	if card:
		initialize_card(card)
	else:
		# 如果没有启用的牌包，则创建任意牌包
		card = CardFactory.create_random_card()
		if card:
			initialize_card(card)
		else:
			push_error("无法创建任何牌包")


func initialize_random_by_enable_tag() -> void:
	var card = CardFactory.create_random_card_by_enable_tag()
	if card:
		initialize_card(card)
	else:
		# 如果没有启用的牌包，则创建任意牌包
		card = CardFactory.create_random_card()
		if card:
			initialize_card(card)
		else:
			push_error("无法创建任何牌包")