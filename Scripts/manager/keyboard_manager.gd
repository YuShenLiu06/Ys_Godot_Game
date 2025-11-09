extends Node

# 键盘管理器 - 统一处理键盘输入，避免冲突
# 使用单例模式管理键盘输入的优先级和上下文

enum InputContext {
	GAMEPLAY,    # 游戏进行中的输入
	UI_PAUSE,    # 暂停界面的输入
	UI_MENU,     # 其他菜单界面的输入
	DIALOGUE     # 对话界面的输入
}

var current_context: InputContext = InputContext.GAMEPLAY #定义的枚举类型
var input_stack: Array[InputContext] = []

# 信号定义
signal pause_requested()  # 暂停请求信号
signal resume_requested()  # 恢复请求信号

func _ready() -> void:
	# 设置为单例，确保只有一个键盘管理器实例
	process_mode = Node.PROCESS_MODE_ALWAYS #属性中的始终处理（就是右侧检查里面的）

func _unhandled_input(event: InputEvent) -> void: #在键盘被按下的时候会自动调用该函数
	# 只处理键盘按键事件
	if not event is InputEventKey:
		return
	
	# 只处理按键按下事件
	if not event.pressed:
		return
	
	# 根据当前上下文处理输入
	match current_context:
		InputContext.GAMEPLAY:
			_handle_gameplay_input(event)
		InputContext.UI_PAUSE:
			_handle_pause_ui_input(event)
		InputContext.UI_MENU:
			_handle_menu_ui_input(event)
		InputContext.DIALOGUE:
			_handle_dialogue_input(event)

# 处理游戏进行中的输入
func _handle_gameplay_input(event: InputEventKey) -> void:
	if event.keycode == KEY_ESCAPE:
		# 在游戏进行中，ESC键触发暂停
		pause_requested.emit()

# 处理暂停界面的输入
func _handle_pause_ui_input(event: InputEventKey) -> void:
	if event.keycode == KEY_ESCAPE:
		# 在暂停界面中，ESC键触发恢复游戏
		resume_requested.emit()

# 处理其他菜单界面的输入
func _handle_menu_ui_input(event: InputEventKey) -> void:
	# 可以根据需要添加其他菜单界面的ESC键处理逻辑
	if event.keycode == KEY_ESCAPE:
		# 默认行为：关闭当前菜单，返回到上一个上下文
		pop_context()

# 处理对话界面的输入
func _handle_dialogue_input(event: InputEventKey) -> void:
	# 可以根据需要添加对话界面的ESC键处理逻辑
	if event.keycode == KEY_ESCAPE:
		# 默认行为：跳过对话或关闭对话界面
		pop_context()

# 推送新的输入上下文
func push_context(context: InputContext) -> void:
	input_stack.append(current_context)
	current_context = context
	print("[KeyboardManager] 切换到上下文: ", context)

# 弹出当前输入上下文，返回到上一个
func pop_context() -> void:
	if input_stack.size() > 0:
		current_context = input_stack.pop_back()
		print("[KeyboardManager] 返回到上下文: ", current_context)
	else:
		# 如果没有上一个上下文，默认返回到游戏进行中
		current_context = InputContext.GAMEPLAY
		print("[KeyboardManager] 返回到默认上下文: ", current_context)

# 直接设置输入上下文（清空栈）
func set_context(context: InputContext) -> void:
	current_context = context
	input_stack.clear()
	print("[KeyboardManager] 设置上下文为: ", context)

# 获取当前输入上下文
func get_context() -> InputContext:
	return current_context

# 检查是否在UI上下文中
func is_in_ui_context() -> bool:
	return current_context != InputContext.GAMEPLAY

# 检查是否在暂停界面
func is_in_pause_context() -> bool:
	return current_context == InputContext.UI_PAUSE