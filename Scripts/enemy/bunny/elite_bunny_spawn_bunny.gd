extends Node2D

@export var normal_bunny_scene: PackedScene
@export var spawn_radius: float = 30
@export var wait_time_before_spawn: float = 0.51
var face_derection

func _ready() -> void:
	SignalBus.Choose_time.connect(Callable(self, "Clear_itself"))

	print("Elite_bunny: Spawning normal bunny on death.")
	await get_tree().create_timer(wait_time_before_spawn).timeout
	spawn_normal_bunny()
	queue_free()

func get_radom_position(radius: float) -> Vector2:
	var angle = randf() * TAU
	var r = radius * sqrt(randf())
	var x = r * cos(angle)
	var y = r * sin(angle)
	return Vector2(x, y)

# 使用随机数生成normal_bunny
func spawn_normal_bunny() -> void:
	print("Elite_bunny: Spawning normal bunnies.")
	if !SceneManager.validate_scene(normal_bunny_scene):
		print("[Elif_bunny]: normal_bunny_scene is not valid.")
		return
	var spawn_count = randi() % 3 + 2 # 生成2到4只normal_bunny
	for i in spawn_count:
		var normal_bunny = normal_bunny_scene.instantiate() as Normal_bunny
		var offset = get_radom_position(spawn_radius)
		normal_bunny.position = position + offset
		normal_bunny.face_derection = face_derection
		get_tree().current_scene.add_child(normal_bunny)

func Clear_itself(_is_choose_time: bool = false) -> void:
	queue_free()