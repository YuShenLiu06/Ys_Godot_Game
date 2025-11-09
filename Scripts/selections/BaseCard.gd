# 牌包基类 - 定义所有牌包的通用接口和行为
# 遵循SOLID原则中的单一职责和开闭原则
class_name BaseCard
extends RefCounted

# 牌包基本信息
var card_name: String = ""
var description: String = ""
var icon_path: String = ""

# 牌包标签 - 单一字符串，代表牌包分组（如"basic"、"expansion1"、"expansion2"等）
var card_tag: String = "basic"  # 默认为基础牌包
var is_enabled: bool = true

# 虚函数 - 子类必须实现
# 初始化牌包
func initialize() -> void:
	push_error("BaseCard.initialize() 必须被子类重写喵！")

# 应用牌包效果
func apply_effect() -> void:
	push_error("BaseCard.apply_effect() 必须被子类重写喵！")

# 获取牌包显示文本
func get_display_text() -> String:
	return description

# 获取牌包名称
func get_card_name() -> String:
	return card_name

# 获取牌包图标路径
func get_icon_path() -> String:
	return icon_path

# 检查牌包是否可以应用（可选重写）
func can_apply() -> bool:
	return is_enabled

# 牌包应用前的回调（可选重写）
func on_before_apply() -> void:
	pass

# 牌包应用后的回调（可选重写）
func on_after_apply() -> void:
	pass

# 标签相关方法
func has_tag(tag: String) -> bool:
	return card_tag == tag

func set_tag(tag: String) -> void:
	card_tag = tag

func get_tag() -> String:
	return card_tag

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled

# 检查牌包标签是否在指定的标签列表中
func is_tag_in_list(tags: Array[String]) -> bool:
	return card_tag in tags