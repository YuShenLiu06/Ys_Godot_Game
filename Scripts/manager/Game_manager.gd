extends Node2D

@export var Slime_scene : PackedScene
@export var Spawn_timer : Timer
@export var Score : int = 0
@export var Score_label : Label
@export var Game_over_label : Label
@export var Exp_label : Label
@export var Level_label : Label
@export var Card_Selection_Label : Label
@export var Exp : int = 0
@export var Level : int = 0
@export var Bullet_Damage : float = 1
@export var Choose_scene : PackedScene
@export var Exp_coefficient : float = 1.0  #经验值获取系数
@export var Camera : Camera2D  # 引用相机节点，用于屏幕抖动效果

#explosion_chain相关全局变量
@export var Ultimate_exposion_chain : int = 0
@export var explosion_chain_cof_damage : float = 0.5
@export var explosion_chain_cof_probability : float = 1 #爆炸链触发概率

#判断用

var Is_Spawn_slime : bool = true


func _ready() -> void:
	# ConfigManager.load_config()
	$Mask.visible = false
	Set_damage(1)
	SignalBus.bullet_model = 0
	#用于初始化信号链接
	#sel专用连接区
	SignalBus.Sel_Exp_obtain.connect(Callable(self,"Sel_Exp_obtain"))
	SignalBus.Sel_Bullet_damage.connect(Callable(self,"Sel_Bullet_damage"))
	SignalBus.Close_Choose_time.connect(Callable(self,"Close_Choose_time"))
	SignalBus.Choose_time.connect(Callable(self,"sign_Is_Spawn_slime"))
	SignalBus.Pause_game.connect(Callable(self,"on_pause_game"))
	
	#explosion_chain相关信号连接
	SignalBus.Sel_Explosion_Chain.connect(Callable(self,"sel_explosion_chain_apply"))
	SignalBus.Sel_Explosion_Chain_Damage.connect(Callable(self,"sel_explosion_chain_damage_apply"))
	SignalBus.Sel_Explosion_Chain_Probability.connect(Callable(self,"sel_explosion_chain_probability_apply"))
	
	# 连接键盘管理器的信号
	KeyboardManager.pause_requested.connect(_on_pause_requested)
	KeyboardManager.resume_requested.connect(_on_resume_requested)
	
	# 确保相机引用正确
	# 如果在编辑器中没有手动设置相机引用，则自动查找子节点中的Camera2D
	if Camera == null:
		Camera = $Camera2D

func _physics_process(delta: float) -> void:
	# 游戏暂停时不处理游戏逻辑
	# 移除直接的ESC键检测，改为使用KeyboardManager的信号系统
		
	if Is_Spawn_slime:
		Spawn_timer.wait_time -= 0.03 * delta #每秒减少0.03s的史莱姆生成时间
		Spawn_timer.wait_time = clamp(Spawn_timer.wait_time,0.2,3) #将Spawn_timer.wait_time大小限制在1与3之间
	
	#文本更新
	Score_label.text = "Score: " + str(Score)
	Exp_label.text = "Exp:" + str(Exp) + "/" + str(ceil(10*(1.5**Level)))
	Level_label.text = "Level:" + str(Level)
	
	#经验等级更新
	if Exp >= ceil(10*(1.5**Level)):
		Exp=0
		Level+=1
		# SignalBus.Is_choose_time = true
		if Level%10 == 0 or Level == 1:
			Start_choose_time(2) #初始选卡
		else:
			Start_choose_time()

func Spawn_slime():
	# print("[debug][gm] Spawn_slime:",Is_Spawn_slime)
	if !Is_Spawn_slime:
		return
		#两边都有1/2的概率出兵
	if randi()%2==0:
		Spawn_enemy(Slime_scene,-345,32,112,1,1.1)		
	else:
		Spawn_enemy(Slime_scene,136,32,112,-1,1.1)		

func Spawn_enemy(enemy_scene : PackedScene,position_x,range_1: int,range_2: int,enemy_face_derection: int,enemy_health_cof_base : float) -> void:
	var enemy_node = enemy_scene.instantiate()
	# 先设置不会被子类初始化覆盖的属性
	enemy_node.face_derection = enemy_face_derection
	enemy_node.position = Vector2(position_x,randf_range(range_1,range_2))
	enemy_node.Bullet_damage = Bullet_Damage
	enemy_node.Exp_coefficient = Exp_coefficient
	
	# 传递explosion_chain相关参数
	enemy_node.Ultimate_exposion_chain = Ultimate_exposion_chain
	enemy_node.explosion_chain_cof_damage = explosion_chain_cof_damage
	enemy_node.explosion_chain_cof_probability = explosion_chain_cof_probability

	# 把节点加入场景，使其 _ready/_init 在场景上下文中运行，
	# 然后再基于子类可能在初始化时设置的基准 Health 计算并覆盖最终血量
	get_tree().current_scene.add_child(enemy_node)

	# 现在基于实例当前的 Health 值计算最终血量并应用
	enemy_node.Health = comput_enemy_health(enemy_node.Health, enemy_health_cof_base) #设置血量

func show_game_over():
	Game_over_label.visible = true

func Start_choose_time(type: int = 1): #选项界面创建
	$Mask.visible = true #蒙版可视性
	#全局信号
	SignalBus.Choose_time.emit(true)
	
	# 根据type设置卡牌选择说明文字
	match type:
		1:
			Card_Selection_Label.text = "选择一个强化"
			Choose_Cards()
		2:
			Card_Selection_Label.text = "选择一个终极天赋"
			Choose_Cards("ultimate",2) #初始选卡
	
	# 显示卡牌选择说明Label
	Card_Selection_Label.visible = true

	
func Close_Choose_time(): #选项界面关闭
	$Mask.visible = false
	Card_Selection_Label.visible = false
	SignalBus.Choose_time.emit(false)

# 新的牌包创建方法 - 使用新的牌包架构
func Spawn_Card_New(Card_scene : PackedScene, position: Vector2, tag: String, type: int = 1): #对于Card创建
	var Card_node = Card_scene.instantiate()
	Card_node.position = position
	var card
	# 使用新的随机初始化方法
	match type:
		1:
			card = Card_node.initialize_random_by_enable_tag()
		2:
			card = Card_node.initialize_by_tag(tag)
	
	get_tree().current_scene.add_child(Card_node)
	return card

func Set_damage(Set_damage: float): #子弹伤害设置函数
	Bullet_Damage = Set_damage
	SignalBus.Get_bullet_damage.emit(Set_damage)

func comput_enemy_health(enemy_init_health: float,cof_base: float): #血量成长函数
	# print("[debug][enemy] enemy health is:",enemy_init_health)
	# print("[debug][player] player bullet damage is:",Bullet_Damage)
	return enemy_init_health**(cof_base**Level)

func toggle_pause(): #暂停切换
	# 切换暂停状态
	SignalBus.Is_paused = !SignalBus.Is_paused
	SignalBus.Pause_game.emit(SignalBus.Is_paused)
	get_tree().paused = SignalBus.Is_paused

# 处理键盘管理器的暂停请求
func _on_pause_requested():
	if not SignalBus.Is_paused:
		toggle_pause()
		KeyboardManager.set_context(KeyboardManager.InputContext.UI_PAUSE)

# 处理键盘管理器的恢复请求
func _on_resume_requested():
	if SignalBus.Is_paused:
		toggle_pause()
		KeyboardManager.set_context(KeyboardManager.InputContext.GAMEPLAY)

func Choose_Cards(tag: String = "",type: int = 1): #选项卡牌选择实现
	
	var Card_1
	if type == 1:
		Card_1 = Spawn_Card_New(Choose_scene, Vector2(-276, 55),"basic",2)
	else:
		Card_1 = Spawn_Card_New(Choose_scene, Vector2(-276, 55),tag,type)
	Card_1.is_enabled = false 
	var Card_2 = Spawn_Card_New(Choose_scene, Vector2(-117, 55),tag,type)
	Card_2.is_enabled = false
	var Card_3 = Spawn_Card_New(Choose_scene, Vector2(42, 55),tag,type)
	Card_1.is_enabled = true
	Card_2.is_enabled = true

# sel相关函数实现

func Sel_Bullet_damage(cof):
	Set_damage(Bullet_Damage*cof)

func Sel_Exp_obtain(cof):
	Exp_coefficient*=cof

#explosion_chain相关处理函数
func sel_explosion_chain_apply():
	# 启用爆炸连锁效果
	print("[Game Manager] explosion_chain enabled")
	#牌包新增tag "explosion_chain" 用于启用爆炸连锁牌包
	if CardFactory.enabled_tags.find("explosion_chain") == -1:
		CardFactory.enabled_tags.append("explosion_chain")
	
	Ultimate_exposion_chain += 1

#explosion_chain伤害系数应用
func sel_explosion_chain_damage_apply(cof: float):
	explosion_chain_cof_damage *= cof

#explosion_chain概率应用
func sel_explosion_chain_probability_apply(cof: float):
	explosion_chain_cof_probability *= cof
	# 确保概率不超过1.0
	explosion_chain_cof_probability = min(explosion_chain_cof_probability, 1.0)
	print("[Game Manager] explosion_chain_probability updated to:", explosion_chain_cof_probability)

# Sign链接实现
func sign_Is_Spawn_slime(Is_Choose_time):
	Is_Spawn_slime = !Is_Choose_time
	# print("debug_Is_Spawn_slime:",Is_Spawn_slime)

func on_pause_game(is_paused: bool):
	# 暂停时不修改Is_Spawn_slime状态，只处理暂停逻辑
	pass

func screen_shake(strength: float = 5.0, duration: float = 0.3):
	# 检查相机是否存在且具有start_shake方法（即使用了ScreenShake脚本）
	if Camera and Camera.has_method("start_shake"):
		# 调用相机的start_shake方法触发抖动效果
		Camera.start_shake(strength, duration)
	
