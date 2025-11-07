extends Area2D
class_name Enemy_father #enemy 父节点(必须在最上方)

@export var Enemy_speed : float = 50
@export var Exp : int = 5
@export var Health : float = 2.0
@export var Bullet_damage :	float = 1
@export var Exp_coefficient : float = 1.0
@export var explosion_damage : int = 3 #产生爆炸的阈值伤害
@export var bullet_explosion_scene : PackedScene
@export var face_derection : int = -1 #1向右 #-1 向左

var injured_wait_time : float = 0.25  # 受击动画持续时间

#控制用变量

var is_dead : bool = false

func _ready() -> void:
	set_face_derection()
	_init()

	#信号连接专用：显式将方法绑定到当前实例，避免签名/解析问题
	SignalBus.Choose_time.connect(Callable(self, "Clear_itself"))
	
	await get_tree().create_timer(15).timeout
	queue_free()

# func _init() -> void:

func Clear_itself(_is_choose_time: bool=false) -> void:

	queue_free()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	position += Vector2(Enemy_speed*face_derection,0) * delta #delta意味着每个帧花费了多少秒 这句话意味着在1s移动100个像素点

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && !is_dead:
		body.Gameover()

func _on_area_entered(area: Area2D) -> void:
	var current_scene = get_tree().current_scene
	# if current_scene:
	# 	print("[%s][debug] Enemy area entered by: %s | current_scene: %s" % [Time.get_unix_time_from_system(), area.name, current_scene.name])
	# else:
	# 	print("[debug] Enemy area entered by: ", area.name, " | current_scene: null")
	if is_dead:
		return
	#如果接触对象是“bullet”scenc
	if area.is_in_group("Bullet"):
		# print("[debug][enemy] Bullet hit detected. Bullet damage:", Bullet_damage, " Enemy health before hit:", Health)
		_on_area_entered_bullet(area)

	if area.is_in_group("explosion"):
		_on_area_entered_explosion(area)
	
	if Health <= 0: #阵亡检测
		_on_area_entered_death_zone(area)
		return

	$AnimatedSprite2D.play("Injured") #受击但并未死亡，播放受击动画
	await get_tree().create_timer(0.25).timeout
	$AnimatedSprite2D.play("idle")

	
func spawn_bullet_explosion(position: Vector2,scale: float):
	var bullet_explosion_instance = bullet_explosion_scene.instantiate()
	bullet_explosion_instance.position = position
	bullet_explosion_instance.explosion_scale = scale
	get_tree().current_scene.add_child(bullet_explosion_instance)

func _on_area_entered_bullet(area: Area2D):
	area.queue_free() # 删除子弹实体
	#如果伤害高于爆炸伤害阈值则生成爆炸
	if Bullet_damage > explosion_damage:
		spawn_bullet_explosion(area.position,set_explosion_scale(1.2,3))
	if area.is_in_group("Bullet") && !is_dead: #并未阵亡扣血
		Health-=Bullet_damage

#通过伤害设置爆炸范围
func set_explosion_scale(cof_base: float,cof_Denominator: int) -> float:  #可以调整底数和分母系数用来调整爆炸的增炸速度
	return clamp(cof_base**(1+(Bullet_damage-explosion_damage)/cof_Denominator), 1.0, 10.0)  # 根据伤害调整爆炸范围，限制在5到20之间

func _on_area_entered_explosion(area: Area2D):
	#处理爆炸伤害 
	Health -= Bullet_damage

func _on_area_entered_death_zone(area: Area2D) -> void:
	$AnimatedSprite2D.play("Death")
	is_dead = true
	get_tree().current_scene.Score += 1
	get_tree().current_scene.Exp += ceil(Exp*Exp_coefficient)  #获得经验*经验系数
	$Death_Sound.play()
	await  get_tree().create_timer(0.6).timeout
	queue_free()

func set_face_derection():
	if face_derection == 1:
		$".".scale.x = -1
	else:
		$".".scale.x = 1

#sel系列
