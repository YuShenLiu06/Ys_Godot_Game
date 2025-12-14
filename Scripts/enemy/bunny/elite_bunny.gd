extends Enemy_father
class_name Elif_bunny

@export var normal_bunny_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var wait_time_before_spawn: float = 1.0

func _init() -> void:
	# 子类特有的初始化（父类的 _ready 会在节点加入场景后调用 _init）
	injured_wait_time = 0.5
	Health = 5
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
	await get_tree().create_timer(1).timeout
	spawn_normal_bunny()

func get_radom_position(radius: float) -> Vector2:
	var angle = randf() * TAU
	var r = radius * sqrt(randf())
	var x = r * cos(angle)
	var y = r * sin(angle)
	return Vector2(x, y)

# 使用随机数生成normal_bunny
func spawn_normal_bunny() -> void:
	if !SceneManager.validate_scene(normal_bunny_scene):
		push_error("[Elif_bunny]: normal_bunny_scene is not valid.")
		return
	var spawn_count = randi() % 3 + 2 # 生成2到4只normal_bunny
	for i in spawn_count:
		var normal_bunny = normal_bunny_scene.instantiate() as Normal_bunny
		var offset = get_radom_position(spawn_radius)
		normal_bunny.position = position + offset
		normal_bunny.face_derection = face_derection
		get_tree().current_scene.add_child(normal_bunny)
