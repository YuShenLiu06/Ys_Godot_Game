extends Node2D

@onready var continue_button = $continue
@onready var exit_button = $exit
@onready var master_volume_slider = $sub_volume_slider
@onready var sfx_volume_slider = $sub_volume_slider2 #绑定按钮

func _ready() -> void:
	VolumeManager.setup_ui_sounds(self)
	visible = false  # 初始时隐藏暂停UI
	
	# 连接按钮信号
	# continue_button.pressed.connect(_on_continue_pressed)
	# exit_button.pressed.connect(_on_exit_pressed)
	
	# 连接暂停信号
	SignalBus.Pause_game.connect(_on_pause_game)
	
	# 连接键盘管理器的信号
	KeyboardManager.resume_requested.connect(_on_resume_requested)

func _on_pause_game(is_paused: bool) -> void:
	visible = is_paused
	if is_paused:
		# 暂停游戏时显示UI
		show_pause_ui()
		# 设置键盘管理器上下文为暂停界面
		KeyboardManager.set_context(KeyboardManager.InputContext.UI_PAUSE)
	else:
		# 继续游戏时隐藏UI
		hide_pause_ui()
		# 恢复键盘管理器上下文为游戏进行中
		KeyboardManager.set_context(KeyboardManager.InputContext.GAMEPLAY)

# 处理键盘管理器的恢复请求
func _on_resume_requested():
	if visible:
		SignalBus.Is_paused = false
		SignalBus.Pause_game.emit(false)
		get_tree().paused = false

func show_pause_ui() -> void:
	visible = true
	# 确保音量控制也显示
	master_volume_slider.visible = true
	sfx_volume_slider.visible = true

func hide_pause_ui() -> void:
	visible = false
	# 隐藏音量控制
	master_volume_slider.visible = false
	sfx_volume_slider.visible = false

# func _on_continue_pressed() -> void:
# 	# 继续游戏
# 	SignalBus.Is_paused = false
# 	SignalBus.Pause_game.emit(false)
# 	get_tree().paused = false

# func _on_exit_pressed() -> void:
# 	# 退出游戏
# 	get_tree().quit()

