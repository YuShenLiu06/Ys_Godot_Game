extends Button

func _ready() -> void:
	# 连接键盘管理器的信号
	KeyboardManager.resume_requested.connect(_on_resume_requested)

func _on_pressed() -> void:
	# 继续游戏
	SignalBus.Is_paused = false
	SignalBus.Pause_game.emit(false)
	get_tree().paused = false

# 处理键盘管理器的恢复请求
func _on_resume_requested():
	# 模拟按钮点击
	_on_pressed()
