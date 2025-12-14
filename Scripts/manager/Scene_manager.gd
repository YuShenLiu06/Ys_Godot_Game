# Scene_manager.gd
# 场景管理器 - 提供安全的场景实例化功能，包含null检查和错误处理
# 作者：浮浮酱
# 版本：1.0

extends Node
class_name SceneManager

# 场景实例化结果枚举
enum SceneInstantiateResult {
	SUCCESS,
	NULL_SCENE,
	INVALID_SCENE,
	FAILED_TO_INSTANTIATE
}

# 安全场景实例化函数
# @param scene: PackedScene - 要实例化的场景
# @param parent_node: Node - 父节点，如果为null则使用当前场景
# @param position: Vector2 - 实例化后的位置（可选）
# @return: Array - [结果状态, 实例化的节点或错误信息]
static func safe_instantiate_scene(scene: PackedScene, parent_node: Node = null, position: Vector2 = Vector2.ZERO) -> Array:
	# 检查场景是否为null
	if scene == null:
		print("[Scene Manager] 错误：尝试实例化的场景为null")
		return [SceneInstantiateResult.NULL_SCENE, "场景为null"]
	
	# 检查场景是否有效
	if not scene.can_instantiate():
		print("[Scene Manager] 错误：场景无法实例化，可能路径错误或场景损坏")
		return [SceneInstantiateResult.INVALID_SCENE, "场景无效或损坏"]
	
	# 尝试实例化场景
	var instance = scene.instantiate()
	if instance == null:
		print("[Scene Manager] 错误：场景实例化失败")
		return [SceneInstantiateResult.FAILED_TO_INSTANTIATE, "场景实例化失败"]
	
	# 设置父节点
	if parent_node == null:
		parent_node = Engine.get_main_loop().current_scene
	
	# 添加到场景树
	parent_node.add_child(instance)
	
	# 设置位置（如果提供了位置且节点支持position属性）
	if position != Vector2.ZERO and instance.has_method("set_position"):
		instance.position = position
	elif position != Vector2.ZERO and instance.has_property("position"):
		instance.position = position
	
	print("[Scene Manager] 成功实例化场景: ", scene.resource_path)
	return [SceneInstantiateResult.SUCCESS, instance]

# 批量安全实例化场景
# @param scenes: Array[PackedScene] - 要实例化的场景数组
# @param parent_node: Node - 父节点
# @param positions: Array[Vector2] - 位置数组（可选）
# @return: Array - [成功数量, 失败数量, 结果数组]
static func batch_safe_instantiate_scenes(scenes: Array[PackedScene], parent_node: Node = null, positions: Array[Vector2] = []) -> Array:
	var success_count = 0
	var fail_count = 0
	var results = []
	
	for i in range(scenes.size()):
		var scene = scenes[i]
		var pos = Vector2.ZERO
		
		# 如果提供了位置数组且索引有效，使用对应位置
		if positions.size() > i:
			pos = positions[i]
		
		var result = safe_instantiate_scene(scene, parent_node, pos)
		results.append(result)
		
		if result[0] == SceneInstantiateResult.SUCCESS:
			success_count += 1
		else:
			fail_count += 1
	
	print("[Scene Manager] 批量实例化完成 - 成功: ", success_count, ", 失败: ", fail_count)
	return [success_count, fail_count, results]

# 验证场景是否有效
# @param scene: PackedScene - 要验证的场景
# @return: bool - 场景是否有效
static func validate_scene(scene: PackedScene) -> bool:
	if scene == null:
		return false
	
	if not scene.can_instantiate():
		return false
	
	return true

# 获取场景的根节点类型
# @param scene: PackedScene - 要检查的场景
# @return: String - 根节点类型名称，如果无效则返回空字符串
static func get_scene_root_type(scene: PackedScene) -> String:
	if not validate_scene(scene):
		return ""
	
	var instance = scene.instantiate()
	if instance == null:
		return ""
	
	var type_name = instance.get_class()
	instance.queue_free()  # 立即释放临时实例
	
	return type_name

# 安全的场景切换
# @param scene_path: String - 要切换到的场景路径
# @return: bool - 切换是否成功
static func safe_change_scene(scene_path: String) -> bool:
	if scene_path.is_empty():
		print("[Scene Manager] 错误：场景路径为空")
		return false
	
	if not ResourceLoader.exists(scene_path):
		print("[Scene Manager] 错误：场景文件不存在: ", scene_path)
		return false
	
	var tree = Engine.get_main_loop() as SceneTree
	if tree == null:
		print("[Scene Manager] 错误：无法获取场景树")
		return false
	
	var error = tree.change_scene_to_file(scene_path)
	if error != OK:
		print("[Scene Manager] 错误：场景切换失败，错误码: ", error)
		return false
	
	print("[Scene Manager] 成功切换到场景: ", scene_path)
	return true