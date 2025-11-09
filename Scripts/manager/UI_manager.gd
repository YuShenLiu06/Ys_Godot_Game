extends Node

# UI场景引用
@export var pause_ui_scene: PackedScene
@export var volume_control_ui_scene: PackedScene

# 当前活动的UI实例
var current_pause_ui: Node2D = null
var current_volume_ui: Control = null

# UI层级管理
@onready var ui_layer: CanvasLayer = $CanvasLayer

func _ready() -> void:
	# 连接信号
	SignalBus.pause_game_requested.connect(_on_pause_game_requested)
	SignalBus.resume_game_requested.connect(_on_resume_game_requested)
	SignalBus.volume_control_requested.connect(_on_volume_control_requested)

# 暂停游戏并显示暂停UI
func _on_pause_game_requested() -> void:
	if current_pause_ui != null:
		return # 已经显示暂停UI
	
	# 创建暂停UI实例
	current_pause_ui = pause_ui_scene.instantiate()
	ui_layer.add_child(current_pause_ui)
	
	# 暂停游戏
	get_tree().paused = true

# 恢复游戏并隐藏暂停UI
func _on_resume_game_requested() -> void:
	if current_pause_ui == null:
		return
	
	# 移除暂停UI实例
	current_pause_ui.queue_free()
	current_pause_ui = null
	
	# 恢复游戏
	get_tree().paused = false

# 显示音量控制UI
func _on_volume_control_requested() -> void:
	if current_volume_ui != null:
		return # 已经显示音量控制UI
	
	# 创建音量控制UI实例
	current_volume_ui = volume_control_ui_scene.instantiate()
	ui_layer.add_child(current_volume_ui)

# 隐藏音量控制UI
func hide_volume_control() -> void:
	if current_volume_ui == null:
		return
	
	# 移除音量控制UI实例
	current_volume_ui.queue_free()
	current_volume_ui = null

# 通用UI显示方法
func show_ui(ui_scene: PackedScene) -> Node:
	var ui_instance = ui_scene.instantiate()
	ui_layer.add_child(ui_instance)
	return ui_instance

# 通用UI隐藏方法
func hide_ui(ui_instance: Node) -> void:
	if ui_instance != null and is_instance_valid(ui_instance):
		ui_instance.queue_free()
