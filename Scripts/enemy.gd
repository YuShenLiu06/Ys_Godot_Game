extends Area2D

@export var slime_speed : float = -100
@export var exp : int = 5
@export var Health : float = 2
@export var bullet_damage : int = 1
@export var Exp_coefficient : float = 1.0

var is_dead : bool = false

func _ready() -> void:
	
	
	#信号连接专用
	SignalBus.Get_bullet_damage.connect(On_change_damage) 
	SignalBus.Choose_time.connect(clear)
		
	await get_tree().create_timer(15).timeout
	queue_free()

	#clear()
	
func On_change_damage(New_damage): #伤害更新
	bullet_damage=New_damage

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if !SignalBus.Is_choose_time: #如果不是选择时间，那么暂停移动
		position += Vector2(slime_speed,0) * delta #delta意味着每个帧花费了多少秒 这句话意味着在1s移动100个像素点


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D && !is_dead:
		body.Gameover()

func clear():
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if SignalBus.Is_choose_time || is_dead:
		return
	area.queue_free() # 删除子弹实体
	if area.is_in_group("Bullet") && !is_dead: #并未阵亡扣血
		Health-=bullet_damage
	
	if Health<=0: #本体死亡
		$AnimatedSprite2D.play("Death")
		is_dead = true
		get_tree().current_scene.Score += 1
		get_tree().current_scene.Exp += ceil(exp*Exp_coefficient)  #获得经验*经验系数
		$Death_Sound.play()
		await  get_tree().create_timer(0.6).timeout
		queue_free()
		return
	$AnimatedSprite2D.play("Injured") #受击但并未死亡，播放受击动画
	await get_tree().create_timer(0.25).timeout
	$AnimatedSprite2D.play("idle")

#sel系列
