# 牌包工厂类 - 负责创建和管理所有牌包
# 遵循工厂模式，便于扩展新的牌包类型
class_name CardFactory
extends RefCounted

# 动态加载所有牌包类的缓存(预加载5个牌包)
static var _all_cards_cache: Array[BaseCard] = [
	BulletDamageCard.new(),
	BulletFireRateCard.new(),
	ExpGainCard.new(),
	TrackingBulletMaxLifetimeCard.new(),
	TrackingBulletTurnSpeedCard.new()
]
# 启用的标签列表 - 可以在运行时设置
static var enabled_tags: Array[String] = ["basic", "tracking_bullet"]  # 默认启用基础牌包和追踪子弹牌包

# 设置启用的标签
static func set_enabled_tags(tags: Array[String]) -> void:
	enabled_tags = tags

# 添加启用的标签
static func add_enabled_tag(tag: String) -> void:
	if tag not in enabled_tags:
		enabled_tags.append(tag)

# 移除启用的标签
static func remove_enabled_tag(tag: String) -> void:
	enabled_tags.erase(tag)

# 获取当前启用的标签
static func get_enabled_tags() -> Array[String]:
	return enabled_tags.duplicate()

# 递归遍历目录并加载所有牌包类
static func _load_cards_from_directory(dir_path: String) -> void:
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("无法打开目录: " + dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path + "/" + file_name
		
		# 如果是目录，递归处理
		if dir.current_is_dir():
			# 跳过 . 和 .. 目录
			if file_name != "." and file_name != "..":
				_load_cards_from_directory(full_path)
		# 如果是.gd文件，尝试加载
		elif file_name.ends_with(".gd"):
			var card_script = load(full_path)
			
			if card_script:
				# 检查是否继承自BaseCard
				var card_instance = card_script.new()
				if card_instance is BaseCard:
					_all_cards_cache.append(card_instance)
					print("成功加载牌包: " + file_name + " tag: " + card_instance.get_tag())
				else:
					push_warning("文件 " + file_name + " 不是有效的BaseCard子类")
			else:
				push_error("无法加载牌包脚本: " + full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# 动态加载所有牌包类
static func load_all_cards() -> Array[BaseCard]:
	# 如果缓存已存在，直接返回
	if _all_cards_cache.size() > 0:
		return _all_cards_cache
	
	# 从selections_cards目录开始递归加载
	_load_cards_from_directory("res://Scripts/selections/selections_cards")
	
	if _all_cards_cache.size() == 0:
		push_error("未找到任何有效的牌包类")
	else:
		print("总共加载了 " + str(_all_cards_cache.size()) + " 个牌包")
	
	return _all_cards_cache

# 获取所有牌包（使用动态加载）
static func get_all_cards() -> Array[BaseCard]:
	return load_all_cards()

# 创建随机牌包（所有可用牌包）
static func create_random_card() -> BaseCard:
	var all_cards = get_all_cards()
	if all_cards.size() > 0:
		return all_cards[randi() % all_cards.size()]
	else:
		push_error("没有可用的牌包")
		return null

# 根据标签创建牌包
static func create_card_by_tag(tag: String) -> BaseCard:
	
	var matching_cards: Array[BaseCard] = []
	var all_cards = get_all_cards()
	for card in all_cards:
		if card.has_tag(tag):
			matching_cards.append(card)
	
	if matching_cards.size() > 0:
		return matching_cards[randi() % matching_cards.size()]
	else:
		push_error("没有找到包含标签 '" + tag + "' 的牌包")
		return null

# 获取所有启用的牌包（根据enabled_tags筛选）
static func get_all_enabled_cards() -> Array[BaseCard]:
	var enabled_cards: Array[BaseCard] = []
	var all_cards = get_all_cards()
	for card in all_cards:
		if card.is_enabled and card.is_tag_in_list(enabled_tags):
			enabled_cards.append(card)
	
	return enabled_cards

# 创建随机启用的牌包
static func create_random_enabled_card() -> BaseCard:
	var enabled_cards = get_all_enabled_cards()
	if enabled_cards.size() > 0:
		return enabled_cards[randi() % enabled_cards.size()]
	else:
		push_error("没有启用的牌包")
		return null

# 创建标签被启用的牌包
static func create_random_card_by_enable_tag() ->BaseCard:
	var all_cards = get_all_enabled_cards()
	if all_cards.size() > 0:
		return all_cards[randi() % all_cards.size()]
	else:
		push_error("没有可用的牌包")
		return null