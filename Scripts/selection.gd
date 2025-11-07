extends Node2D

@export var Choose_functon : int = 1 #当前卡牌选项

var method_init = [null,Bullet_Halve_init,Bullet_damage_init,Exp_obtain_init] #初始化函数组
var metohd_on_press = [null,Bullet_Halve_on_press,Bullet_damage_on_press,Exp_obtain_on_press]


func _ready() -> void: #初始化
	method_init[Choose_functon].call()
	
	#信号链接
	SignalBus.Close_Choose_time.connect(clear)

func _on_button_pressed() -> void: #按钮被按下的时候
	metohd_on_press[Choose_functon].call()
	SignalBus.Close_Choose_time.emit()

func _process(delta: float) -> void:
	pass

func clear():
	queue_free()

#卡牌功能实现

#选项1
func Bullet_Halve_init():
	
	#$Label.text = "开火时间*"+str(cof)
	$Label.text = "开火时间*0.75"

func Bullet_Halve_on_press():
	var cof : float = 0.75
	SignalBus.Sel_Bullet_fire_timer.emit(cof)
	
#选项2
func Bullet_damage_init():
	#子弹伤害
	#$Label.text = "子弹伤害*"+str(cof)
	$Label.text = "子弹伤害*1.5"

func Bullet_damage_on_press():
	var cof : float = 1.5
	SignalBus.Sel_Bullet_damage.emit(cof)

#选项3

func Exp_obtain_init():
	#子弹伤害
	#$Label.text = "经验获取*"+str(cof) 
	$Label.text = "经验获取*2"

func Exp_obtain_on_press():
	var cof : float = 2.0
	SignalBus.Sel_Exp_obtain.emit(cof)
	
	
