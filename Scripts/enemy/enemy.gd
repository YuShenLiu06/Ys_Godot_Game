extends Area2D
class_name Enemy_father # enemy 父节点(必须在最上方)

# 敌人基本属性
@export var Enemy_speed: float = 50
@export var Exp: int = 3
@export var Health: float = 2.0
@export var Bullet_damage: float = 1
@export var Exp_coefficient: float = 1.0
@export var face_derection: int = -1 # 1向右 #-1 向左

# 爆炸相关属性
@export var explosion_damage: int = 2 # 产生爆炸的阈值伤害
@export var bullet_explosion_scene: PackedScene
@export var explosion_chain_cof_probability: float = 0.25 # 爆炸连锁概率
@export var explosion_chain_cof_damage: float = 0.5 # 爆炸连锁伤害系数
@export var is_explosion_chain: bool = false # 是否连锁过

# 动画相关属性
var injured_wait_time: float = 0.25 # 受击动画持续时间

#ultimate相关变量
@export var Ultimate_exposion_chain : int = 0

#控制用变量

var is_dead: bool = false

# 暂停免疫的计时器变量
var game_time_elapsed: float = 0.0 # 累计游戏时间（不包括暂停时间）
var lifetime: float = 15.0 # 敌人存活时间（秒）
var injured_time_elapsed: float = 0.0 # 受伤动画已播放时间
var death_time_elapsed: float = 0.0 # 死亡动画已播放时间
var is_injured: bool = false # 是否正在播放受伤动画

func _ready() -> void:
	set_face_derection()
	_init()

	#信号连接专用：显式将方法绑定到当前实例，避免签名/解析问题
	SignalBus.Choose_time.connect(Callable(self, "Clear_itself"))
	SignalBus.Pause_game.connect(Callable(self, "on_pause_game"))

# func _init() -> void:

func Clear_itself(_is_choose_time: bool = false) -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	# 只在非暂停状态下累计时间
	if not SignalBus.Is_paused:
		game_time_elapsed += delta
		
		# 检查自动销毁计时器
		if !is_dead and game_time_elapsed >= lifetime:
			queue_free()
			return
		
		if is_dead:
			# 检查死亡动画计时器
			death_time_elapsed += delta
			if death_time_elapsed >= 0.6:
				queue_free()
			return
		
		# 检查受伤动画计时器
		if is_injured:
			injured_time_elapsed += delta
			if injured_time_elapsed >= injured_wait_time:
				$AnimatedSprite2D.play("idle")
				is_injured = false
				injured_time_elapsed = 0.0
	
	if is_dead:
		return
		
	position += Vector2(Enemy_speed * face_derection, 0) * delta # delta意味着每个帧花费了多少秒 这句话意味着在1s移动100个像素点

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && !is_dead:
		body.Gameover()

func _on_area_entered(area: Area2D) -> void:
	var current_scene = get_tree().current_scene
	if is_dead:
		return
	#如果接触对象是“bullet”scenc
	if area.is_in_group("Bullet"):
		_on_area_entered_bullet(area)
	elif area.is_in_group("explosion"):
		_on_area_entered_explosion(area)
	else:
		return
	
	if Health <= 0: # 阵亡检测
		_on_area_entered_death_zone(area)
		return

	$AnimatedSprite2D.play("Injured") # 受击但并未死亡，播放受击动画
	# 使用自定义计时器替代await，不受暂停影响
	is_injured = true
	injured_time_elapsed = 0.0

	
func spawn_bullet_explosion(position: Vector2,damage: int = Bullet_damage):
	call_deferred("_spawn_bullet_explosion_deferred", position, damage)



func _spawn_bullet_explosion_deferred(position: Vector2,damage: int):
	var bullet_explosion_instance = bullet_explosion_scene.instantiate()
	bullet_explosion_instance.position = position
	# bullet_explosion_instance.explosion_scale = scale
	bullet_explosion_instance.Bullet_damage = damage
	bullet_explosion_instance.explosion_damage = explosion_damage
	get_tree().current_scene.add_child(bullet_explosion_instance)

func _on_area_entered_bullet(area: Area2D):
	#处理触碰子弹事件
	# 提前保存position，避免area被释放后无法访问
	var area_position = area.position
	area.call_deferred("queue_free") # 使用call_deferred延迟删除子弹实体，避免状态冲突
	#如果伤害高于爆炸伤害阈值则生成爆炸或者点了爆炸的终极天赋
	if Bullet_damage > explosion_damage or Ultimate_exposion_chain > 0:
		spawn_bullet_explosion(area_position)
		is_explosion_chain = true
	if area.is_in_group("Bullet") && !is_dead: # 并未阵亡扣血
		Health -= Bullet_damage

# 当碰上爆炸
func _on_area_entered_explosion(area: Area2D):
	# 提前保存Bullet_damage，避免area被释放后无法访问
	var area_bullet_damage = area.Bullet_damage
	
	if Ultimate_exposion_chain > 0:
		# 根据explosion_chain_cof_probability来概率生成
		# print("[Enemy] 爆炸连锁")
		# print("randf():", randf())
		print("explosion_chain_cof_probability:", explosion_chain_cof_probability)
		if randf() < explosion_chain_cof_probability and !is_explosion_chain:
			is_explosion_chain = true
			await get_tree().create_timer(0.2).timeout
			spawn_bullet_explosion(position, area_bullet_damage * explosion_chain_cof_damage)
			# print("生成连锁爆炸")
	Health -= area_bullet_damage
	await get_tree().create_timer(1).timeout
	is_explosion_chain = false


func _on_area_entered_death_zone(area: Area2D) -> void:
	$AnimatedSprite2D.play("Death")
	is_dead = true
	get_tree().current_scene.Score += 1
	get_tree().current_scene.Exp += ceil(Exp * Exp_coefficient) # 获得经验*经验系数
	$Death_Sound.play()
	
	# 使用自定义计时器替代await，不受暂停影响
	death_time_elapsed = 0.0

func set_face_derection():
	if face_derection == 1:
		$".".scale.x = -1
	else:
		$".".scale.x = 1


# 暂停信号处理函数
func on_pause_game(is_paused: bool) -> void:
	# 暂停状态下不处理任何逻辑，时间不会累计
	pass

#sel系列
