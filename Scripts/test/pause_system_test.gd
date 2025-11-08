extends Node

# 暂停系统测试脚本
# 用于验证暂停系统的完整性

func _ready() -> void:
	print("=== 暂停系统测试开始 ===")
	
	# 测试信号连接
	test_signal_connections()
	
	# 测试初始状态
	test_initial_state()
	
	print("=== 暂停系统测试完成 ===")

func test_signal_connections():
	print("\n1. 测试信号连接...")
	
	# 检查SignalBus是否有暂停信号
	if SignalBus.has_signal("Pause_game"):
		print("✓ SignalBus.Pause_game 信号存在")
	else:
		print("✗ SignalBus.Pause_game 信号不存在")
	
	# 检查SignalBus是否有Is_paused变量
	if "Is_paused" in SignalBus:
		print("✓ SignalBus.Is_paused 变量存在")
	else:
		print("✗ SignalBus.Is_paused 变量不存在")

func test_initial_state():
	print("\n2. 测试初始状态...")
	
	# 检查初始暂停状态
	if SignalBus.Is_paused == false:
		print("✓ 游戏初始状态为未暂停")
	else:
		print("✗ 游戏初始状态为暂停")
	
	# 检查游戏树是否暂停
	if get_tree().paused == false:
		print("✓ 游戏树初始状态为未暂停")
	else:
		print("✗ 游戏树初始状态为暂停")

func _input(event: InputEvent) -> void:
	# 测试暂停键响应
	if event.is_action_pressed("pause"):
		print("\n3. 测试暂停键响应...")
		print("暂停键被按下，当前暂停状态: ", SignalBus.Is_paused)
		
		# 检查状态切换
		if SignalBus.Is_paused:
			print("✓ 游戏已暂停")
		else:
			print("✓ 游戏已继续")