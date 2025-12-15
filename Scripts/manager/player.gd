extends CharacterBody2D

@export var move_speed : float = 70
@export var animator : AnimatedSprite2D
@export var Face_direction : int = 1 #1向右 #-1 向左
@export var bullet_scene : PackedScene
@export var tracking_bullet_scene : PackedScene
# @export var bullet_model : int = 0 #默认0为
@export var bullet_damage : int = 1

# tracking_bullet增强属性
var tracking_bullet_turn_speed_multiplier: float = 0.5  # 转向速度倍数
var tracking_bullet_max_lifetime_bonus: float = 0.0  # 最大生存时间加成

# ultimate天赋加点次数

@export var Ultimate_tracking_bullet : int = 0
@export var Ultimate_exposion_chain : int = 0

# 三连发相关变量
var is_triple_shot_enabled: bool = false  # 是否启用三连发
var triple_shot_count: int = 0  # 当前三连发计数
var triple_shot_interval: float = 0.1  # 三连发子弹间隔时间

# 移动射击相关变量
var is_moving_shooting : bool = false

#sign 判断用

var Is_processing : bool = true
var Is_physics_processing : bool = true
var Is_Game_Over : bool = false
var Is_on_fire : bool = true

func _ready() -> void: #游戏开始时被运行
	
	#信号链接用
	SignalBus.Sel_Bullet_fire_timer.connect(Sel_Bullet_fire_timer)
	SignalBus.Sel_Tracking_Bullet_Turn_Speed.connect(Sel_Tracking_Bullet_Turn_Speed)
	SignalBus.Sel_Tracking_Bullet_Max_Lifetime.connect(Sel_Tracking_Bullet_Max_Lifetime)
	SignalBus.Get_bullet_damage.connect(Get_bullet_damage)
	SignalBus.Choose_time.connect(Callable(self,"sign_Is_processing"))
	SignalBus.Choose_time.connect(Callable(self,"sign_physics_process"))
	SignalBus.Choose_time.connect(Callable(self,"sign_Is_on_fire"))
	SignalBus.Pause_game.connect(Callable(self,"sign_Is_processing"))
	SignalBus.Sel_Tracking_Bullet.connect(Callable(self,"sel_tracking_bullet_apply"))

	# sel_rein相关信号连接
	SignalBus.Sel_Rein.connect(Callable(self, "Sel_init"))
	
	# 三连发觉醒信号连接
	SignalBus.Sel_Triple_Shot.connect(Callable(self, "sel_triple_shot_apply"))
	
	# 移动射击觉醒信号连接
	SignalBus.Sel_Moving_Shooting.connect(Callable(self, "sel_moving_shooting_apply"))

	velocity = Vector2(50,0) #(x,y)
	$Timer.wait_time=1
	
func _process(delta: float) -> void:
	# 检测ESC键暂停游戏
	
	if !Is_processing:
		return
	if velocity == Vector2.ZERO || Is_Game_Over && !SignalBus.Is_choose_time:
		$Running_Sound.stop()
	elif !$Running_Sound.playing:
		$Running_Sound.play()
	
	# 根据鼠标位置自动转向
	update_facing_direction()
	
	# 注释掉原来的键盘转向，改为鼠标控制
	# if Input.is_action_just_pressed("left") && Face_direction==1: #转向检测
	# 	turn()
	# 	Face_direction=-1
	# if Input.is_action_just_pressed("right") && Face_direction==-1: #转向检测
	# 	turn()
	# 	Face_direction=1

func _physics_process(delta: float) -> void:	#以固定时间运行
	turn(Face_direction)
	if !Is_Game_Over && Is_physics_processing: 
		velocity=Input.get_vector("left","right","up","down")*move_speed
		
		if velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			animator.play("run")
		
		move_and_slide()#move_and_slide 已经自动处理了delta无需再次手动处理
		
func Gameover():
	if ! Is_Game_Over :
		animator.play("Gameover")
		Is_Game_Over=true
		get_tree().current_scene.show_game_over()
		$Gameover_Sound.play()
		$Restartimer.start()
		
		#await get_tree().create_timer(3).timeout #delay 3$Restartimer.start()


func _on_fire() -> void: #根据Timer信号
	
	if !(velocity == Vector2.ZERO || is_moving_shooting) || Is_Game_Over || !Is_on_fire:
		return
		
	# 如果启用了三连发，则发射三发子弹
	if is_triple_shot_enabled:
		fire_triple_shot()
	else:
		fire_single_bullet()

# 发射单发子弹
func fire_single_bullet():
	# 根据设置选择子弹类型
	$Fire_Sound.play()
	var bullet_node
	match SignalBus.bullet_model:
		SignalBus.bullet_models.tracking_bullet:
			if tracking_bullet_scene:
				bullet_node = tracking_bullet_scene.instantiate()
				# 设置追踪子弹的玩家引用
				bullet_node.Damage = bullet_damage
				bullet_node.node_player = self
				# 应用增强属性
				bullet_node.turn_speed *= (tracking_bullet_turn_speed_multiplier*1.21**clamp((Ultimate_tracking_bullet-1),0,INF))
				bullet_node.max_lifetime += (tracking_bullet_max_lifetime_bonus+ 0.6*clamp((Ultimate_tracking_bullet-1),0,INF))
			else:
				# 如果追踪子弹场景未设置，回退到普通子弹
				bullet_node = bullet_scene.instantiate()
				bullet_node.face_derection = Face_direction
				bullet_node.Damage = bullet_damage
				# 设置玩家引用，用于子弹朝向鼠标
				bullet_node.node_player = self
		SignalBus.bullet_models.normal_bullet:
			# 默认使用普通子弹
			bullet_node = bullet_scene.instantiate()
			bullet_node.face_derection = Face_direction
			bullet_node.Damage = bullet_damage
			# 设置玩家引用，用于子弹朝向鼠标
			bullet_node.node_player = self
	
	bullet_node.position = position
	get_tree().current_scene.add_child(bullet_node)

# 发射三连发子弹
func fire_triple_shot():
	# 创建三个子弹，每个间隔一定时间
	for i in range(3):
		# 延迟发射子弹
		await get_tree().create_timer(i * triple_shot_interval).timeout
		fire_single_bullet()
	
func _reload_scence() -> void:
	get_tree().reload_current_scene()
	
func turn(dercetion: int = 1) -> void:
	if transform.get_scale().y != dercetion:
		scale.x = -1
#sel用
func Sel_Bullet_fire_timer(cof):
	$Timer.wait_time*=cof
func Get_bullet_damage(damage):
	bullet_damage = damage

#init 函数

func Sel_init() -> void:
	# 初始化sel相关属性
	tracking_bullet_turn_speed_multiplier = 0.5  # 转向速度倍数
	tracking_bullet_max_lifetime_bonus = 0.0  # 最大生存时间加成
	$Timer.wait_time = 1  # 子弹发射间隔
	if is_triple_shot_enabled:
		# 如果三连发已启用，调整发射间隔
		$Timer.wait_time *= 1.5

func sel_triple_shot_apply() -> void:
	# 启用三连发觉醒
	is_triple_shot_enabled = true
	$Timer.wait_time *= 1.5  # 增加发射间隔以适应三连发
	print("三连发觉醒已启用！")

func sel_moving_shooting_apply() -> void:
	# 启用移动射击觉醒
	is_moving_shooting = true
	print("移动射击觉醒已启用！")

# ultimate相关函数实现

# sel_tracking_bullet相关

func sel_tracking_bullet_apply():
	# 切换到追踪子弹模式

	#牌包新增tag "tracking_bullet" 用于启用追踪子弹牌包

	if CardFactory.enabled_tags.find("tracking_bullet") == -1:
		CardFactory.enabled_tags.append("tracking_bullet")

	if SignalBus.bullet_model != SignalBus.bullet_models.tracking_bullet:
		SignalBus.bullet_model = SignalBus.bullet_models.tracking_bullet
	Ultimate_tracking_bullet += 1

func sel_explosion_chain_apply():
	# 启用爆炸连锁效果

	#牌包新增tag "explosion_chain" 用于启用爆炸连锁牌包

	if CardFactory.enabled_tags.find("explosion_chain") == -1:
		CardFactory.enabled_tags.append("explosion_chain")

	Ultimate_exposion_chain += 1

# Sign链接实现
func sign_Is_processing(Is_Choose_time):
	Is_processing = !Is_Choose_time
	# print("debug_Is_processing:",Is_processing)

func sign_physics_process(Is_Choose_time):
	Is_physics_processing = !Is_Choose_time
	# print("debug_Is_physics_processing:",Is_physics_processing)

func sign_Is_on_fire(Is_Choose_time):
	Is_on_fire = !Is_Choose_time
	# print("debug_Is_on_fire:",Is_on_fire)

# tracking_bullet增强信号处理
func Sel_Tracking_Bullet_Turn_Speed(cof: float):
	tracking_bullet_turn_speed_multiplier *= cof
	print("追踪子弹转向速度倍数更新为: ", tracking_bullet_turn_speed_multiplier)

func Sel_Tracking_Bullet_Max_Lifetime(increase: float):
	tracking_bullet_max_lifetime_bonus += increase
	print("追踪子弹最大生存时间加成更新为: ", tracking_bullet_max_lifetime_bonus)

func update_facing_direction() -> void:
	# 获取鼠标位置
	var mouse_position = get_global_mouse_position()
	
	# 计算鼠标相对于玩家的方向
	var mouse_direction = (mouse_position - global_position).normalized()
	
	# 根据鼠标方向更新玩家朝向
	if mouse_direction.x > 0:
		Face_direction = 1
	elif mouse_direction.x < 0:
		Face_direction = -1
	# 如果鼠标在垂直方向，保持当前朝向不变
