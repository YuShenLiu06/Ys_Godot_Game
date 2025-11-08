extends Node

enum Bus {Master} #音频总线枚举

@onready var sfx : Node = $sfx #音效播放器节点引用

func play_sfx(name :String) -> void:
	var sfx_player : AudioStreamPlayer = sfx.get_node(name) as AudioStreamPlayer
	if sfx_player != null:
		sfx_player.play()
	else:
		push_error("[Error] volume_manager:play_sfx() 节点不存在 : %s" % name)

func setup_ui_sounds(node: Node) -> void:
	# 检查当前节点是否是按钮
	if node is Button or TextureButton:
		if node.has_signal("pressed"):
			node.pressed.connect(play_sfx.bind("ui_press")) 
			node.mouse_entered.connect(play_sfx.bind("ui_focus"))
			# 解释
			# node作为按钮节点其中的pressed
	
	# 递归遍历所有子节点
	for child in node.get_children():
		setup_ui_sounds(child)

func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index) #通过音频索引返回当前db值
	return db_to_linear(db)

func set_volume(bus_index: int,set_db: float) -> void:
	var db := linear_to_db(set_db)
	AudioServer.set_bus_volume_db(bus_index,db)
