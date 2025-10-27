extends Node2D

@export var Slime_scene : PackedScene
@export var Spawn_timer : Timer
@export var Score : int = 0
@export var Score_label : Label
@export var Game_over_label : Label
@export var Exp_label : Label
@export var Level_label : Label
@export var Exp : int = 0
@export var Level : int = 0
@export var Bullet_Damage : float = 1
@export var Choose_scene : PackedScene
@export var Exp_coefficient : float = 1.0  #经验值获取系数


func _ready() -> void:
	$Mask.visible = false
	#Set_damage(2)
	
	#用于初始化信号链接
	#sel专用连接区
	SignalBus.Sel_Exp_obtain.connect(Sel_Exp_obtain)
	SignalBus.Sel_Bullet_damage.connect(Sel_Bullet_damage)
	SignalBus.Close_Choose_time.connect(Close_Choose_time)

func _physics_process(delta: float) -> void:
	Spawn_timer.wait_time -= 0.2 * delta #每秒减少0.2s的史莱姆生成时间
	Spawn_timer.wait_time = clamp(Spawn_timer.wait_time,1,3) #将Spawn_timer.wait_time大小限制在1与3之间
	
	#文本更新
	Score_label.text = "Score: " + str(Score)
	Exp_label.text = "Exp:" + str(Exp)
	Level_label.text = "Level:" + str(Level)
	
	#经验等级更新
	if Exp >= ceil(10*(1.5**Level)):
		Exp=0
		Level+=1
		SignalBus.Is_choose_time = true
		Choose_time()

func Spawn_slime():
	if !SignalBus.Is_choose_time:
		Spawn_enemy(Slime_scene,32,112)		

func Spawn_enemy(enemy_scene : PackedScene,range_1: int,range_2: int) -> void:
	var enemy_node = enemy_scene.instantiate()
	enemy_node.position = Vector2(136,randf_range(range_1,range_2))
	enemy_node.Bullet_damage = Bullet_Damage
	enemy_node.Exp_coefficient = Exp_coefficient
	get_tree().current_scene.add_child(enemy_node)

func show_game_over():
	Game_over_label.visible = true

func Choose_time(): #选项界面创建
	$Mask.visible = true #蒙版可视性
	#全局信号
	SignalBus.Choose_time.emit()
	
	#生成三张卡片
	Spawn_Card(Choose_scene,-276,55,randi_range(1,SignalBus.tot_Choose_functon))
	Spawn_Card(Choose_scene,-117,55,randi_range(1,SignalBus.tot_Choose_functon))
	Spawn_Card(Choose_scene,42,55,randi_range(1,SignalBus.tot_Choose_functon))
	
	
func Spawn_Card(Card_scene : PackedScene,Positon_x : int,Positon_y,Select_fuc : int): #对于Card创建
	var Card_node = Card_scene.instantiate()
	Card_node.Choose_functon = Select_fuc
	Card_node.position = Vector2(Positon_x,Positon_y)
	get_tree().current_scene.add_child(Card_node)

	
func Close_Choose_time(): #选项界面关闭
	$Mask.visible = false
	SignalBus.Is_choose_time = false

func Set_damage(Set_damage: float): #子弹上海设置函数
	Bullet_Damage = Set_damage
	SignalBus.Get_bullet_damage.emit(Set_damage)
	#emit_signal("On_change_damage",Set_damage)

# sel相关函数实现

func Sel_Bullet_damage(cof):
	Set_damage(Bullet_Damage*cof)

func Sel_Exp_obtain(cof):
	Exp_coefficient*=cof
#func Sel_Bullet_Halve_on_press():
	
