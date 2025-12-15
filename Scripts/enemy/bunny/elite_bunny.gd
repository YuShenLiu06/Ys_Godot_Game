extends Enemy_father
class_name Elif_bunny

@export var spawn_bunny_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var wait_time_before_spawn: float = 0.2

func _init() -> void:
	# 子类特有的初始化（父类的 _ready 会在节点加入场景后调用 _init）
	injured_wait_time = 0.5
	Health = 10
	Enemy_speed = 30
	enemy_weight = 1
	Exp = 15
	is_enabled = false
	lifetime = 50

func get_health() -> float:
	return Health

func set_health(new_health: float) -> void:
	Health = new_health

func _death() -> void:
	print("Elite_bunny: Spawning normal bunny on death.")
	# await get_tree().create_timer(wait_time_before_spawn).timeout
	if ! SceneManager.validate_scene(spawn_bunny_scene):
		print("Elite_bunny: spawn_bunny_scene is not valid!")
		return
	var Node_spawn_bunny_scence = spawn_bunny_scene.instantiate()
	Node_spawn_bunny_scence.position = position
	Node_spawn_bunny_scence.face_derection = face_derection
	get_tree().current_scene.add_child(Node_spawn_bunny_scence)
