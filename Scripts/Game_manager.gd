extends Node2D

@export var Slime_scene : PackedScene
@export var Spawn_timer : Timer
@export var Score : int = 0
@export var Score_label : Label
@export var Game_over_label : Label
@export var Exp_label : Label
@export var Level_label : Label
@export var Is_Slime_spawn : bool = false
@export var Exp : int = 0
@export var Level : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	Spawn_timer.wait_time -= 0.2 * delta #每秒减少0.2s的史莱姆生成时间
	Spawn_timer.wait_time = clamp(Spawn_timer.wait_time,1,3) #将Spawn_timer.wait_time大小限制在1与3之间
	Score_label.text = "Score: " + str(Score)
	Exp_label.text = "Exp:" + str(Exp)
	Level_label.text = "Level:" + str(Level)
	if Exp >= ceil(10*(1.5**Level)):
		Exp=0
		Level+=1

func Spawn_slime():
	Spawn_enemy(Slime_scene,32,112)		

func Spawn_enemy(enemy_scene : PackedScene,range_1: int,range_2: int) -> void:
	var enemy_node = enemy_scene.instantiate()
	enemy_node.position = Vector2(136,randf_range(range_1,range_2))
	get_tree().current_scene.add_child(enemy_node)

func show_game_over():
	Game_over_label.visible = true
