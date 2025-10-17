extends CharacterBody2D

@export var move_speed : float = 50
@export var animator : AnimatedSprite2D
@export var Face_direction : int = 1 #1向右 #-1 向左
@export var bullet_scene : PackedScene

var Is_Game_Over : bool = false

func _ready() -> void: #游戏开始时被运行
	
	#信号链接用
	SignalBus.Sel_Bullet_fire_timer.connect(Sel_Bullet_fire_timer)

	velocity = Vector2(50,0) #(x,y)
	
func _process(delta: float) -> void:
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
	if !Is_Game_Over&&!SignalBus.Is_choose_time: 
		velocity=Input.get_vector("left","right","up","down")*move_speed
		
		if velocity == Vector2.ZERO:
			animator.play("idle")
		else:
			animator.play("run")
		
		move_and_slide()
		
func Gameover():
	if ! Is_Game_Over && !SignalBus.Is_choose_time :
		animator.play("Gameover")
		Is_Game_Over=true
		get_tree().current_scene.show_game_over()
		$Gameover_Sound.play()
		$Restartimer.start()
		
		#await get_tree().create_timer(3).timeout #delay 3$Restartimer.start()


func _on_fire() -> void: #根据Timer信号
	
	if velocity != Vector2.ZERO || Is_Game_Over || SignalBus.Is_choose_time:
		return
	
	$Fire_Sound.play()
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position
	bullet_node.face_derection = Face_direction
	get_tree().current_scene.add_child(bullet_node)
	
	


func _reload_scence() -> void:
	get_tree().reload_current_scene()
	
func turn():
	#if SignalBus.Choose_time:
		#return
	$".".scale.x = -1


#sel用
func Sel_Bullet_fire_timer(cof):
	$Timer.wait_time*=cof
