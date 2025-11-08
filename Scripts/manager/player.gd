extends CharacterBody2D

@export var move_speed : float = 70
@export var animator : AnimatedSprite2D
@export var Face_direction : int = 1 #1向右 #-1 向左
@export var bullet_scene : PackedScene

#sign 判断用

var Is_processing : bool = true
var Is_physics_processing : bool = true
var Is_Game_Over : bool = false
var Is_on_fire : bool = true

func _ready() -> void: #游戏开始时被运行
	
	#信号链接用
	SignalBus.Sel_Bullet_fire_timer.connect(Sel_Bullet_fire_timer)
	SignalBus.Choose_time.connect(Callable(self,"sign_Is_processing"))
	SignalBus.Choose_time.connect(Callable(self,"sign_physics_process"))
	SignalBus.Choose_time.connect(Callable(self,"sign_Is_on_fire"))

	velocity = Vector2(50,0) #(x,y)
	
func _process(delta: float) -> void:
	if !Is_processing:
		return
	if velocity == Vector2.ZERO || Is_Game_Over && !SignalBus.Is_choose_time:
		$Running_Sound.stop()
	elif !$Running_Sound.playing:
		$Running_Sound.play()
	if Input.is_action_just_pressed("left") && Face_direction==1: #转向检测
		turn()
		Face_direction=-1
	if Input.is_action_just_pressed("right") && Face_direction==-1: #转向检测
		turn()
		Face_direction=1

func _physics_process(delta: float) -> void:	#以固定时间运行
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
	
	if velocity != Vector2.ZERO || Is_Game_Over || !Is_on_fire:
		return
	
	$Fire_Sound.play()
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position
	bullet_node.face_derection = Face_direction
	get_tree().current_scene.add_child(bullet_node)
	
	


func _reload_scence() -> void:
	get_tree().reload_current_scene()
	
func turn():
	$".".scale.x = -1


#sel用
func Sel_Bullet_fire_timer(cof):
	$Timer.wait_time*=cof


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
