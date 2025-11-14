extends Control

# 调试控制台脚本
# 用于游戏内调试和测试功能

# UI引用
@onready var console_container: VBoxContainer = $ConsoleContainer
@onready var input_line: LineEdit = $ConsoleContainer/InputContainer/InputLine
@onready var output_container: VBoxContainer = $ConsoleContainer/ScrollContainer/OutputContainer
@onready var scroll_container: ScrollContainer = $ConsoleContainer/ScrollContainer
@onready var title_label: Label = $ConsoleContainer/TitleLabel

# 控制台状态
var is_visible: bool = false
var command_history: Array[String] = []
var history_index: int = 0
var max_history: int = 50

# 指令处理
var commands: Dictionary = {}

# 游戏管理器引用
var game_manager: Node2D
var player: CharacterBody2D

# 字体引用
var console_font: FontFile

func _ready() -> void:
	# 设置为始终处理，不受游戏暂停影响
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 初始化字体
	console_font = load("res://AssetBundle/Uranus_Pixel_11Px.ttf")
	if console_font:
		if title_label:
			title_label.add_theme_font_override("font", console_font)
		if input_line:
			input_line.add_theme_font_override("font", console_font)
	
	# 初始化指令
	_init_commands()
	
	# 连接信号
	if input_line:
		if not input_line.text_submitted.is_connected(_on_command_submitted):
			input_line.text_submitted.connect(_on_command_submitted)
	
	# 初始隐藏控制台
	visible = false

func _init_commands() -> void:
	# 注册所有指令
	commands["help"] = _cmd_help
	commands["clear"] = _cmd_clear
	commands["exp"] = _cmd_exp
	commands["level"] = _cmd_level
	commands["bullet"] = _cmd_bullet
	commands["ultimate"] = _cmd_ultimate
	commands["choose"] = _cmd_choose
	commands["spawn"] = _cmd_spawn

func _input(event: InputEvent) -> void:
	# 检测控制台开关快捷键 (F1)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		toggle_console()
		return
	
	# 如果控制台未激活，不处理其他输入
	if not is_visible:
		return
	
	# 处理历史记录导航
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_UP:
			_navigate_history(-1)
		elif event.keycode == KEY_DOWN:
			_navigate_history(1)

func toggle_console() -> void:
	is_visible = not is_visible
	visible = is_visible
	
	if is_visible:
		# 获取游戏管理器和玩家引用
		game_manager = get_tree().current_scene
		player = game_manager.get_node_or_null("Player")
		
		# 激活输入框
		if input_line:
			input_line.grab_focus()
			input_line.caret_column = input_line.text.length()
		
		# 切换键盘管理器上下文
		KeyboardManager.push_context(KeyboardManager.InputContext.DEBUG_CONSOLE)
		
		# 显示欢迎消息
		_add_output("=== 调试控制台已激活 ===", Color.CYAN)
		_add_output("输入 'help' 查看可用指令", Color.YELLOW)
	else:
		# 恢复键盘管理器上下文
		KeyboardManager.pop_context()

func _on_command_submitted(command_text: String) -> void:
	if command_text.is_empty():
		return
	
	# 添加到历史记录
	_add_to_history(command_text)
	
	# 显示输入的指令
	_add_output("> " + command_text, Color.WHITE, true)
	
	# 解析并执行指令
	var args = command_text.split(" ", false)
	if args.size() > 0:
		var cmd_name = args[0].to_lower()
		if commands.has(cmd_name):
			# 执行指令
			commands[cmd_name].call(args)
		else:
			_add_output("未知指令: " + cmd_name, Color.RED)
			_add_output("输入 'help' 查看可用指令", Color.YELLOW)
	
	# 清空输入框
	if input_line:
		input_line.text = ""
	history_index = command_history.size()

func _add_to_history(command: String) -> void:
	command_history.append(command)
	if command_history.size() > max_history:
		command_history.pop_front()

func _navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return
	
	history_index += direction
	history_index = clamp(history_index, 0, command_history.size() - 1)
	
	if history_index == command_history.size():
		if input_line:
			input_line.text = ""
	else:
		if input_line:
			input_line.text = command_history[history_index]

func _add_output(text: String, color: Color = Color.WHITE, is_user_input: bool = false) -> void:
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	if console_font:
		label.add_theme_font_override("font", console_font)
		label.add_theme_font_size_override("font_size", 16)
	
	if output_container:
		output_container.add_child(label)
	
	# 自动滚动到底部
	await get_tree().process_frame
	if scroll_container and scroll_container.get_v_scroll_bar():
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	
	# 同步到引擎调试输出台
	_sync_to_debug_output(text, is_user_input)

# 指令实现
func _cmd_help(args: Array[String]) -> void:
	_add_output("可用指令列表:", Color.CYAN)
	_add_output("exp add <amount> - 增加经验值", Color.WHITE)
	_add_output("level set <amount> - 设置等级", Color.WHITE)
	_add_output("bullet model set <type> - 设置子弹类型 (0:普通, 1:追踪)", Color.WHITE)
	_add_output("ultimate <type> add <amount> - 增加终极技能次数", Color.WHITE)
	_add_output("  type: tracking_bullet, explosion_chain, penetrate", Color.GRAY)
	_add_output("choose <type> - 触发选卡界面", Color.WHITE)
	_add_output("  type: 1 (普通强化), 2 (终极天赋)", Color.GRAY)
	_add_output("spawn <tscn> <x> <y> - 在指定位置生成敌人", Color.WHITE)
	_add_output("  tscn: normal_slime, test_enemy", Color.GRAY)
	_add_output("  x, y: 生成位置的坐标", Color.GRAY)
	_add_output("clear - 清空控制台", Color.WHITE)
	_add_output("help - 显示帮助信息", Color.WHITE)

func _cmd_clear(args: Array[String]) -> void:
	# 清空输出容器
	if output_container:
		for child in output_container.get_children():
			child.queue_free()
	
	_add_output("控制台已清空", Color.GREEN)

func _cmd_exp(args: Array[String]) -> void:
	if args.size() < 3 or args[1] != "add":
		_add_output("用法: /exp add <amount>", Color.RED)
		return
	
	var amount = args[2].to_int()
	if amount <= 0:
		_add_output("经验值必须大于0", Color.RED)
		return
	
	if not game_manager:
		_add_output("错误: 无法获取游戏管理器引用", Color.RED)
		return
	
	game_manager.Exp += amount
	_add_output("增加了 " + str(amount) + " 点经验值", Color.GREEN)
	_add_output("当前经验值: " + str(game_manager.Exp), Color.WHITE)

func _cmd_level(args: Array[String]) -> void:
	if args.size() < 3 or args[1] != "set":
		_add_output("用法: /level set <amount>", Color.RED)
		return
	
	var level = args[2].to_int()
	if level < 0:
		_add_output("等级不能为负数", Color.RED)
		return
	
	if not game_manager:
		_add_output("错误: 无法获取游戏管理器引用", Color.RED)
		return
	
	game_manager.Level = level
	_add_output("等级设置为 " + str(level), Color.GREEN)

func _cmd_bullet(args: Array[String]) -> void:
	if args.size() < 4 or args[1] != "model" or args[2] != "set":
		_add_output("用法: /bullet model set <type>", Color.RED)
		_add_output("type: 0 (普通子弹), 1 (追踪子弹)", Color.YELLOW)
		return
	
	var bullet_type = args[3].to_int()
	if bullet_type < 0 or bullet_type > 1:
		_add_output("子弹类型必须是 0 或 1", Color.RED)
		return
	
	SignalBus.bullet_model = bullet_type
	var type_name = "普通子弹" if bullet_type == 0 else "追踪子弹"
	_add_output("子弹类型设置为: " + type_name, Color.GREEN)

func _cmd_ultimate(args: Array[String]) -> void:
	if args.size() < 4:
		_add_output("用法: /ultimate <type> add <amount>", Color.RED)
		_add_output("type: tracking_bullet, explosion_chain, penetrate", Color.YELLOW)
		return
	
	var ultimate_type = args[1]
	var action = args[2]
	
	if action != "add":
		_add_output("用法: /ultimate <type> add <amount>", Color.RED)
		return
	
	if args.size() < 4:
		_add_output("请指定增加的次数", Color.RED)
		return
	
	var amount = args[3].to_int()
	if amount <= 0:
		_add_output("次数必须大于0", Color.RED)
		return
	
	if not game_manager:
		_add_output("错误: 无法获取游戏管理器引用", Color.RED)
		return
	
	match ultimate_type:
		"tracking_bullet":
			if not player:
				_add_output("错误: 无法获取玩家引用", Color.RED)
				return
			
			# player.Ultimate_tracking_bullet += amount
			for i in range(amount):
				SignalBus.Sel_Tracking_Bullet.emit()
			_add_output("追踪子弹终极技能增加 " + str(amount) + " 次", Color.GREEN)
			_add_output("当前次数: " + str(player.Ultimate_tracking_bullet), Color.WHITE)
		
		"explosion_chain":
			for i in range(amount):
				SignalBus.Sel_Explosion_Chain.emit()
			# game_manager.Ultimate_exposion_chain += amount
			_add_output("爆炸连锁终极技能增加 " + str(amount) + " 次", Color.GREEN)
			_add_output("当前次数: " + str(game_manager.Ultimate_exposion_chain), Color.WHITE)
		
		"penetrate":
			for i in range(amount):
				SignalBus.Sel_Penetrate.emit()
			# game_manager.Ultimate_penetrate += amount
			_add_output("穿透终极技能增加 " + str(amount) + " 次", Color.GREEN)
			_add_output("当前次数: " + str(game_manager.Ultimate_penetrate), Color.WHITE)
		
		_:
			_add_output("未知的终极技能类型: " + ultimate_type, Color.RED)
			_add_output("可用类型: tracking_bullet, explosion_chain, penetrate", Color.YELLOW)

func _cmd_choose(args: Array[String]) -> void:
	if args.size() < 2:
		_add_output("用法: /choose <type>", Color.RED)
		_add_output("type: 1 (普通强化), 2 (终极天赋)", Color.YELLOW)
		return
	
	var choose_type = args[1].to_int()
	if choose_type < 1 or choose_type > 2:
		_add_output("选卡类型必须是 1 或 2", Color.RED)
		return
	
	if not game_manager:
		_add_output("错误: 无法获取游戏管理器引用", Color.RED)
		return
	
	# 调用游戏管理器的Start_choose_time函数
	game_manager.Start_choose_time(choose_type)
	
	var type_name = "普通强化" if choose_type == 1 else "终极天赋"
	_add_output("已触发" + type_name + "选卡界面", Color.GREEN)

func _cmd_spawn(args: Array[String]) -> void:
	if args.size() < 4:
		_add_output("用法: /spawn <tscn> <x> <y>", Color.RED)
		_add_output("tscn: normal_slime, test_enemy", Color.YELLOW)
		_add_output("x, y: 生成位置的坐标", Color.YELLOW)
		return
	
	var enemy_type = args[1]
	var x = args[2].to_float()
	var y = args[3].to_float()
	
	# 验证敌人类型
	if enemy_type != "normal_slime" and enemy_type != "test_enemy":
		_add_output("错误: 不支持的敌人类型: " + enemy_type, Color.RED)
		_add_output("支持的类型: normal_slime, test_enemy", Color.YELLOW)
		return
	
	# 验证坐标
	if is_nan(x) or is_nan(y):
		_add_output("错误: 坐标必须是有效数字", Color.RED)
		return
	
	if not game_manager:
		_add_output("错误: 无法获取游戏管理器引用", Color.RED)
		return
	
	# 加载敌人场景
	var enemy_scene_path = ""
	match enemy_type:
		"normal_slime":
			enemy_scene_path = "res://Scenes/enemy/normal_slime.tscn"
		"test_enemy":
			enemy_scene_path = "res://Scenes/enemy/test_enemy.tscn"
	
	var enemy_scene = load(enemy_scene_path)
	if not enemy_scene:
		_add_output("错误: 无法加载敌人场景: " + enemy_scene_path, Color.RED)
		return
	
	# 调用游戏管理器的Spawn_enemy函数
	var position = Vector2(x, y)
	var enemy_node = enemy_scene.instantiate()
	
	# 设置敌人基本属性
	enemy_node.position = position
	enemy_node.face_derection = 1  # 默认向右
	enemy_node.Bullet_damage = game_manager.Bullet_Damage
	enemy_node.Exp_coefficient = game_manager.Exp_coefficient
	
	# 传递explosion_chain相关参数
	enemy_node.Ultimate_exposion_chain = game_manager.Ultimate_exposion_chain
	enemy_node.explosion_chain_cof_damage = game_manager.explosion_chain_cof_damage
	enemy_node.explosion_chain_cof_probability = game_manager.explosion_chain_cof_probability
	
	# 传递ultimate_penetrate相关参数
	enemy_node.penetrate_damage_cof = game_manager.penetrate_damage_cof
	enemy_node.penetrate_probability = game_manager.penetrate_probability
	enemy_node.Ultimate_penetrate = game_manager.Ultimate_penetrate
	
	# 将敌人添加到场景
	get_tree().current_scene.add_child(enemy_node)
	
	# 计算并设置血量
	var enemy_health_cof_base = 1.1  # 默认血量系数
	enemy_node.Health = game_manager.comput_enemy_health(enemy_node.Health, enemy_health_cof_base)
	
	_add_output("成功在位置 (" + str(x) + ", " + str(y) + ") 生成敌人: " + enemy_type, Color.GREEN)

# 同步输出到引擎调试输出台
func _sync_to_debug_output(text: String, is_user_input: bool = false) -> void:
	# 获取当前时间戳
	var time_dict = Time.get_datetime_dict_from_system()
	var timestamp = "[%04d-%02d-%02d %02d:%02d:%02d]" % [
		time_dict.year, time_dict.month, time_dict.day,
		time_dict.hour, time_dict.minute, time_dict.second
	]
	
	# 根据类型添加前缀
	var prefix = ""
	if is_user_input:
		prefix = "[USER INPUT] "
	else:
		prefix = "[SYSTEM] "
	
	# 输出到引擎调试控制台
	print(timestamp + " " + prefix + text)